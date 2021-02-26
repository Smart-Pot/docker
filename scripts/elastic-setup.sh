#!/bin/bash
echo "Sleeping for ${SLEEP_TIME} second..."
sleep ${SLEEP_TIME};

elastic=$(getent hosts elasticsearch | awk '{ print $1 }')

curl -H 'Content-Type: application/json' \
       -X PUT http://${elastic}:9200/smart-pot_opt \
       -d \
      "{ \
          \"settings\": { \
              \"number_of_shards\": 1, \
              \"analysis\": { \
                  \"filter\": { \
                      \"autocomplete_filter\": { \
                          \"type\":     \"edge_ngram\", \
                          \"min_gram\": 3, \
                          \"max_gram\": 20 \
                      } \
                  }, \
                  \"analyzer\": { \
                      \"autocomplete\": { \
                          \"type\":      \"custom\", \
                          \"tokenizer\": \"standard\", \
                          \"filter\": [ \
                              \"lowercase\", \
                              \"autocomplete_filter\" \
                          ] \
                      } \
                  } \
              } \
          } \
      }"{"acknowledged":true} \


curl -X POST "${elastic}:9200/smart-pot_opt/_close?pretty"

curl -H 'Content-Type: application/json' \
       -X PUT http://${elastic}:9200/smart-pot_opt/_settings \
       -d \
        "{ \
              \"analysis\": { \
                  \"filter\": { \
                      \"autocomplete_filter\": { \
                          \"type\":     \"edge_ngram\", \
                          \"min_gram\": 3, \
                          \"max_gram\": 20 \
                      } \
                  }, \
                  \"analyzer\": { \
                      \"autocomplete\": { \
                          \"type\":      \"custom\", \
                          \"tokenizer\": \"standard\", \
                          \"filter\": [ \
                              \"lowercase\", \
                              \"autocomplete_filter\" \
                          ] \
                      } \
                  } \
              } \
      }"{"acknowledged":true} \


curl -H 'Content-Type: application/json' \
        -X PUT http://${elastic}:9200/smart-pot_opt/_mapping/posts?include_type_name=true \
        -d \
"{\"posts\": { 
        \"properties\": { \
                \"id\": { \
                    \"type\":    \"text\" \
                },
                \"userid\": { 
                    \"type\":    \"text\" \
                }, 
                \"plant\": { 
                    \"type\":    \"text\" ,\
                    \"analyzer\": \"autocomplete\" \
                }, \
                \"info\": { \
                    \"type\":    \"text\" \
                }, \
                \"content\": { \
                    \"type\":    \"text\" \
                },\
                \"envdata\": { 
                    \"type\":\"nested\",\
                    \"properties\": { \
                        \"humidity\":{ \
                        \"type\": \"text\" \
                    },\
                    \"temperature\":{ \
                        \"type\":\"text\" \
                    },\
                    \"light\":{ \
                        \"type\":\"text\" \
                    }\
                    }\
                }, \
                \"like\":{ \
                    \"type\":\"text\" \
                },\
                \"deleted\":{ \
                    \"type\":\"boolean\" \
                },\
                \"date\": { \
                    \"type\": 	\"text\" \
                } \
            } \
	   } \
}"{"acknowledged":true} \


curl -X POST "${elastic}:9200/smart-pot_opt/_open?pretty"
