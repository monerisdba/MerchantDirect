﻿
--Syntax Error: Incorrect syntax near "offlinx_attribution_distribution".
--Syntax Error: Incorrect syntax near "offlinx_visit_v2".
--Syntax Error: Incorrect syntax near CREATE.
--Syntax Error: Incorrect syntax near PROCEDURE.
---- CREATE new offlinx_attribution_distribution table to replace offlinx_attribution_model table
---- repurpose the offlinx_attribution_model
--DROP TABLE IF EXISTS offlinx_attribution_distribution;
--CREATE TABLE
--    offlinx_attribution_distribution
--    (
--        offlinx_attribution_distribution_code CHAR(4)NOT NULL,
--        name VARCHAR(50)NOT NULL,
--        PRIMARY KEY (offlinx_attribution_distribution_code)
--    );
--
---- Add Linear Attribution Distribution
--INSERT into offlinx_attribution_distribution VALUES ('LNAR', 'Linear');
--
---- Add offlinx_attribution_distribution to offlinx_site
--ALTER TABLE offlinx_site
--add offlinx_attribution_distribution CHAR(4) NOT NULL DEFAULT ''
--;
--
---- Set all sites to use Linear model
--UPDATE offlinx_site 
--SET offlinx_attribution_distribution = 'LNAR';
--
---- Add foreign key constraint to offlinx_attribution_distribution
--ALTER table offlinx_site
--ADD FOREIGN KEY (offlinx_attribution_distribution) REFERENCES "offlinx_attribution_distribution" ("offlinx_attribution_distribution_code");
--
---- Insert the new attribution models suppported
--INSERT INTO offlinx_attribution_model (offlinx_attribution_model_code, name) VALUES ('VST1', 'Attribution by Visit - Version 1');
--INSERT INTO offlinx_attribution_model (offlinx_attribution_model_code, name) VALUES ('TXN1', 'Attribution by Transaction - Version 1');
--
---- Set all existing to use attribution by visit
--UPDATE offlinx_site 
--set offlinx_attribution_model = 'VST1'
--;
--
---- Remove the linear attribution model from offlinx_attribution_model
--DELETE FROM offlinx_attribution_model
--WHERE offlinx_attribution_model_code = 'LNAR';
--
--DROP TABLE IF EXISTS offlinx_transaction_trace;
--CREATE TABLE
--    offlinx_transaction_trace
--    (
--        offlinx_transaction_trace_id BIGINT NOT NULL IDENTITY,
--        offlinx_transaction_id BIGINT NOT NULL,
--        browser_id VARCHAR(50) NOT NULL,
--        PRIMARY KEY (offlinx_transaction_trace_id)
--    );
--    
--CREATE INDEX offlinx_transaction_trace_browser
--ON offlinx_transaction_trace (browser_id);
--
--CREATE UNIQUE INDEX offlinx_transaction_trace_tx_browser
--ON offlinx_transaction_trace (offlinx_transaction_id, browser_id);
--
--DROP TABLE IF EXISTS offlinx_transaction_attribution;
--CREATE TABLE
--    offlinx_transaction_attribution
--    (
--        offlinx_transaction_attribution_id BIGINT NOT NULL IDENTITY,
--        offlinx_visit_id BIGINT NOT NULL,
--        offlinx_transaction_trace_id BIGINT NOT NULL,
--        PRIMARY KEY (offlinx_transaction_attribution_id),
--        FOREIGN KEY (offlinx_visit_id) REFERENCES "offlinx_visit_v2"
--        ("offlinx_visit_id"),
--        FOREIGN KEY (offlinx_transaction_trace_id) REFERENCES "offlinx_transaction_trace"
--        ("offlinx_transaction_trace_id")
--    );
--    
--CREATE UNIQUE INDEX offlinx_attribution_visit
--ON offlinx_transaction_attribution (offlinx_visit_id, offlinx_transaction_trace_id);
--
--CREATE INDEX offlinx_attribution_transaction_trace
--ON offlinx_transaction_attribution (offlinx_transaction_trace_id);
--
---- attribution traced used in OfflinxTracedTransactionAttributionProcessor
----
--DROP PROCEDURE attribute_traced_transaction;
----/
--CREATE PROCEDURE attribute_traced_transaction @OfflinxTransactionID BIGINT,  @BrowserID VARCHAR(50), @TransactionTimestamp DATETIME2, @OfflinxSiteID BIGINT
--AS
--        MERGE offlinx_transaction_attribution ota USING ( 
--                SELECT ott.offlinx_transaction_trace_id , ov.offlinx_visit_id   
--                FROM  offlinx_transaction_trace ott    
--                INNER JOIN offlinx_visit_v2 ov ON ott.browser_id = ov.browser_id 
--                INNER JOIN offlinx_site os ON ov.offlinx_site_id = os.offlinx_site_id 
--                WHERE  ott.offlinx_transaction_id = @OfflinxTransactionID AND ott.browser_id = @BrowserID
--                AND ov.visit_timestamp BETWEEN DATEADD(day,-1*os.attribution_window_days, @TransactionTimestamp) AND @TransactionTimestamp AND ov.offlinx_site_id = @OfflinxSiteID    
--        )  AS visit ON ota.offlinx_visit_id = visit.offlinx_visit_id and ota.offlinx_transaction_trace_id = visit.offlinx_transaction_trace_id 
--        WHEN NOT MATCHED THEN INSERT (offlinx_visit_id, offlinx_transaction_trace_id) VALUES (visit.offlinx_visit_id, visit.offlinx_transaction_trace_id) 
--        OUTPUT INSERTED.offlinx_visit_id;
--/



GO