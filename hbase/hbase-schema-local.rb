create_namespace 'l'
 
create 'l:event', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create 'l:event_idx_account_profile_receiptTime_createTime_sequence', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create 'l:event_idx_receiptTime_account_profile_createTime_sequence', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
 
create 'l:insight', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create 'l:insight_idx_timestamp_account_profile_uri', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
 
create 'l:metric', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create 'l:metric_idx_account_profile_uri_timestamp', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create 'l:metric_idx_timestamp_account_profile_uri', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
 
