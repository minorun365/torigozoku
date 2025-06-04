import json
import uuid
import os
import boto3
import streamlit as st
from botocore.exceptions import ClientError
from botocore.eventstream import EventStreamError

# 環境変数の設定（secrets.tomlから）
if "aws" in st.secrets:
    os.environ["AWS_ACCESS_KEY_ID"] = st.secrets["aws"]["AWS_ACCESS_KEY_ID"]
    os.environ["AWS_SECRET_ACCESS_KEY"] = st.secrets["aws"]["AWS_SECRET_ACCESS_KEY"]
    os.environ["AWS_DEFAULT_REGION"] = st.secrets["aws"]["AWS_DEFAULT_REGION"]

def initialize_session():
    """セッションの初期設定を行う"""
    if "client" not in st.session_state:
        st.session_state.client = boto3.client("bedrock-agent-runtime", region_name="us-west-2")
    
    if "session_id" not in st.session_state:
        st.session_state.session_id = str(uuid.uuid4())
    
    if "messages" not in st.session_state:
        st.session_state.messages = []
    
    if "last_prompt" not in st.session_state:
        st.session_state.last_prompt = None
    
    return st.session_state.client, st.session_state.session_id, st.session_state.messages

def display_chat_history(messages):
    """チャット履歴を表示する"""
    # この関数は使用しなくなったが、互換性のために残す
    pass

def handle_trace_event(event):
    """トレースイベントの処理を行う"""
    if "orchestrationTrace" not in event["trace"]["trace"]:
        return
    
    trace = event["trace"]["trace"]["orchestrationTrace"]
    
    # 「モデル入力」トレースの表示
    if "modelInvocationInput" in trace:
        with st.expander("🤔 思考中…", expanded=False):
            input_trace = trace["modelInvocationInput"]["text"]
            try:
                st.json(json.loads(input_trace))
            except:
                st.write(input_trace)
    
    # 「モデル出力」トレースの表示
    if "modelInvocationOutput" in trace:
        output_trace = trace["modelInvocationOutput"]["rawResponse"]["content"]
        with st.expander("💡 思考がまとまりました", expanded=False):
            try:
                thinking = json.loads(output_trace)["content"][0]["text"]
                if thinking:
                    st.write(thinking)
                else:
                    st.write(json.loads(output_trace)["content"][0])
            except:
                st.write(output_trace)
    
    # 「根拠」トレースの表示
    if "rationale" in trace:
        with st.expander("✅ 次のアクションを決定しました", expanded=True):
            st.write(trace["rationale"]["text"])
    
    # 「ツール呼び出し」トレースの表示
    if "invocationInput" in trace:
        invocation_type = trace["invocationInput"]["invocationType"]
        
        if invocation_type == "AGENT_COLLABORATOR":
            agent_name = trace["invocationInput"]["agentCollaboratorInvocationInput"]["agentCollaboratorName"]
            with st.expander(f"🤖 サブエージェント「{agent_name}」を呼び出し中…", expanded=True):
                st.write(trace["invocationInput"]["agentCollaboratorInvocationInput"]["input"]["text"])

        elif invocation_type == "ACTION_GROUP_CODE_INTERPRETER":
            with st.expander("💻 Pythonコードを実行中…", expanded=False):
                st.write(trace["invocationInput"]["codeInterpreterInvocationInput"])
        
        elif invocation_type == "KNOWLEDGE_BASE":
            with st.expander("📖 ナレッジベースを検索中…", expanded=False):
                st.write(trace["invocationInput"]["knowledgeBaseLookupInput"]["text"])
        
        elif invocation_type == "ACTION_GROUP":
            with st.expander("💻 Lambdaを実行中…", expanded=False):
                st.write(trace['invocationInput']['actionGroupInvocationInput'])
    
    # 「観察」トレースの表示
    if "observation" in trace:
        obs_type = trace["observation"]["type"]
        
        if obs_type == "KNOWLEDGE_BASE":
            with st.expander("🔍 ナレッジベースから検索結果を取得しました", expanded=False):
                st.write(trace["observation"]["knowledgeBaseLookupOutput"]["retrievedReferences"])
        
        elif obs_type == "AGENT_COLLABORATOR":
            agent_name = trace["observation"]["agentCollaboratorInvocationOutput"]["agentCollaboratorName"]
            with st.expander(f"🤖 サブエージェント「{agent_name}」から回答を取得しました", expanded=True):
                st.write(trace["observation"]["agentCollaboratorInvocationOutput"]["output"]["text"])

def invoke_bedrock_agent(client, session_id, prompt):
    """Bedrockエージェントを呼び出す"""
    return client.invoke_agent(
        agentId="BZLSDYG2NF",
        agentAliasId="VC2NDHMJMA",
        sessionId=session_id,
        enableTrace=True,
        inputText=prompt,
    )

def handle_agent_response(response, messages):
    """エージェントのレスポンスを処理する"""
    for event in response.get("completion"):
        if "trace" in event:
            handle_trace_event(event)
        
        if "chunk" in event:
            answer = event["chunk"]["bytes"].decode()
            st.write(answer)
            messages.append({"role": "assistant", "text": answer})

def show_error_popup(exeption):
    """エラーポップアップを表示する"""
    if exeption == "dependencyFailedException":
        error_message = "【エラー】Redshift DBへのクエリーが失敗したようです。ブラウザをリロードして再度お試しください🙏"
    elif exeption == "throttlingException":
        error_message = "【エラー】Bedrockのモデル負荷が高いようです。1分後にブラウザをリロードして再度お試しください🙏（改善しない場合は、モデルを変更するか[サービスクォータの引き上げ申請](https://aws.amazon.com/jp/blogs/news/generative-ai-amazon-bedrock-handling-quota-problems/)を実施ください）"
    st.error(error_message)

def main():
    """メインのアプリケーション処理"""
    client, session_id, messages = initialize_session()
    
    # タイトルの上に入力欄を配置
    st.title("経営コンサル「ベッドロッくん」")
    
    # デフォルト文言付きのテキストエリア
    prompt = st.text_area(
        "質問を入力", 
        "架空の焼鳥店「鳥豪族」の2025年5月の売上データを調べて、経営改善アドバイスをパワポにまとめて！", 
        height=100
    )
    
    # 送信ボタン
    if st.button("質問する", type="primary"):
        if prompt:
            messages.append({"role": "human", "text": prompt})
            
            try:
                response = invoke_bedrock_agent(client, session_id, prompt)
                handle_agent_response(response, messages)
                
            except (EventStreamError, ClientError) as e:
                if "dependencyFailedException" in str(e):
                    show_error_popup("dependencyFailedException")
                elif "throttlingException" in str(e):
                    show_error_popup("throttlingException")
                else:
                    raise e
    
    # アシスタントのメッセージのみ表示（チャットアイコンなし）
    for message in messages:
        if message['role'] == 'assistant':
            st.markdown(message['text'])

if __name__ == "__main__":
    main()