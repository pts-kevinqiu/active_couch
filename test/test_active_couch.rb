require 'minitest/autorun'
require_relative 'active_couch'

class ActiveCouchTest < Minitest::Test
  REPLICATION_TASK = {"pid"=>"<0.148.0>",
                      "checkpoint_interval"=>5000,
                      "checkpointed_source_seq"=>30,
                      "continuous"=>true,
                      "doc_id"=>"DOC_ID",
                      "doc_write_failures"=>0,
                      "docs_read"=>0,
                      "docs_written"=>0,
                      "missing_revisions_found"=>0,
                      "progress"=>100,
                      "replication_id"=>"REPLLICATION_ID",
                      "revisions_checked"=>23,
                      "source"=>"http://admin:*****@example.com:5984/_users/",
                      "source_seq"=>30,
                      "started_on"=>1478620814,
                      "target"=>"http://admin:*****@localhost:5984/_users/",
                      "type"=>"replication",
                      "updated_on"=>1478809684}

  def test_create_replication_task
    task = ActiveCouch::create_task(REPLICATION_TASK)
    assert_equal task.type == ActiveCouch::ReplicationTask
  end
end
