use transactions_tables;
-- risk category

ALTER TABLE transactions_master ADD COLUMN risk_category VARCHAR(20) ;
UPDATE  transactions_master 
                        SET risk_category = CASE
                        WHEN post_auth_risk_score < 0.203767 THEN 'Low_risk'
                        WHEN post_auth_risk_score >= 0.203767 AND post_auth_risk_score <0.400000 THEN 'Medium_risk'
                        ELSE 'High_risk'
                        END;
                        
-- Velocity risk
ALTER TABLE transactions_master ADD COLUMN velocity_risk VARCHAR(20) ;
UPDATE transactions_master 
                        SET velocity_risk = CASE
                        WHEN txn_count_1h >= 7 OR txn_count_24h >= 12 OR failed_txn_count_24h >= 4 THEN 'Suspicious'
                        WHEN txn_count_1h BETWEEN 4 and 6 OR txn_count_24h between 7 and 11 OR failed_txn_count_24h BETWEEN 1 and 3 THEN 'Moderate'
                        ELSE 'Normal'
                        END ;
                        
-- International risk flag
ALTER TABLE transactions_master ADD COLUMN international_risk_flag VARCHAR(30) ;
 UPDATE transactions_master 
    SET international_risk_flag = CASE
        WHEN is_international = 1 AND ip_risk_score >= 0.70 THEN 'Critical Risk'
        WHEN is_international = 1 AND ip_risk_score < 0.70 THEN 'Elevated Risk'
        WHEN is_international = 0 AND ip_risk_score >= 0.70 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END;
    
-- Merchant_risk_status

ALTER TABLE transactions_master ADD COLUMN merchant_risk_status VARCHAR(20) ;
UPDATE transactions_master
                          SET merchant_risk_status = CASE
                          WHEN merchant_risk_score < 0.229556 THEN 'Low Risk'
                          WHEN merchant_risk_score >=0.229556 AND merchant_risk_score<0.345401 THEN 'Medium Risk'
                          ELSE 'High Risk'
                          END ;
-- Fraud_severity
ALTER TABLE transactions_master ADD COLUMN fraud_severity VARCHAR(20) ;
UPDATE transactions_master 
    SET fraud_severity = CASE
        -- Calculate the weighted risk index score on the fly
        WHEN (post_auth_risk_score * 0.45 + merchant_risk_score * 0.35 + ip_risk_score * 0.20) >= 0.75 THEN 'Critical'
        WHEN (post_auth_risk_score * 0.45 + merchant_risk_score * 0.35 + ip_risk_score * 0.20) BETWEEN 0.50 AND 0.7499 THEN 'High'
        WHEN (post_auth_risk_score * 0.45 + merchant_risk_score * 0.35 + ip_risk_score * 0.20) BETWEEN 0.25 AND 0.4999 THEN 'Medium'
        ELSE 'Low'
    END;
    