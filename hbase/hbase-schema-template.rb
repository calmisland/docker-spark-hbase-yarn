create_namespace '${NAMESPACE}'
 
create '${NAMESPACE}:event', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create '${NAMESPACE}:event_idx_account_profile_receiptTime_createTime_sequence', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create '${NAMESPACE}:event_idx_receiptTime_account_profile_createTime_sequence', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
 
create '${NAMESPACE}:insight', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create '${NAMESPACE}:insight_idx_timestamp_account_profile_uri', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
 
create '${NAMESPACE}:metric', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create '${NAMESPACE}:metric_idx_account_profile_uri_timestamp', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
create '${NAMESPACE}:metric_idx_timestamp_account_profile_uri', {NAME => 'a', COMPRESSION => 'GZ', VERSIONS => 1}
 
