-- ========================================
-- Amazon Bedrock ナレッジベース用権限設定
-- ========================================

-- スキーマへの使用権限
GRANT USAGE ON SCHEMA public 
  TO "IAMR:AmazonBedrockExecutionRoleForKnowledgeBase_ivnp2";

-- スキーマ内の全テーブルに対して SELECT 権限
GRANT SELECT ON ALL TABLES IN SCHEMA public
  TO "IAMR:AmazonBedrockExecutionRoleForKnowledgeBase_ivnp2";