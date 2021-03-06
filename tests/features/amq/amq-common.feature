@jboss-amq-6
Feature: Openshift AMQ tests

  @ci
  Scenario: Check that the jboss-amq-6/amq-openshift image contains 6 layers
    Given image is built
     Then image should contain 6 layers

  Scenario: check queue configuration
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                  | value           |
       | AMQ_QUEUES                | one,two,three   |
    Then XML file /opt/amq/conf/activemq.xml should have 3 elements on XPath //amq:destinations/amq:queue
    And XML file /opt/amq/conf/activemq.xml should contain value 1mb on XPath //*[local-name()='policyEntry']/@memoryLimit

  Scenario: check topic configuration
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                  | value           |
       | AMQ_TOPICS                | alpha,beta      |
    Then XML file /opt/amq/conf/activemq.xml should have 2 elements on XPath //amq:destinations/amq:topic

  Scenario: check transport configuration (including SSL versions)
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                    | value         |
       | AMQ_TRANSPORTS              | openwire,amqp |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf |
       | AMQ_KEYSTORE                | broker.ks     |
       | AMQ_KEYSTORE_PASSWORD       | password      |
       | AMQ_TRUSTSTORE              | broker.ts     |
       | AMQ_TRUSTSTORE_PASSWORD     | password      |
    Then XML file /opt/amq/conf/activemq.xml should have 4 elements on XPath //amq:transportConnectors/amq:transportConnector

  Scenario: check transport configuration for enabledProtocols
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                        | value                                |
       | AMQ_TRANSPORTS                  | openwire,amqp,stomp,mqtt             |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR     | /opt/amq/conf                        |
       | AMQ_KEYSTORE                    | broker.ks                            |
       | AMQ_KEYSTORE_PASSWORD           | password                             |
       | AMQ_TRUSTSTORE                  | broker.ts                            |
       | AMQ_TRUSTSTORE_PASSWORD         | password                             |
       | AMQ_TRANSPORT_ENABLED_PROTOCOLS | TLSv1,TLSv1.1,TLSv1.2                |
    Then XML file /opt/amq/conf/activemq.xml should have 8 elements on XPath //amq:transportConnectors/amq:transportConnector
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="ssl" uri="ssl://0.0.0.0:61617?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.enabledProtocols=TLSv1,TLSv1.1,TLSv1.2"/>
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="amqp+ssl" uri="amqp+ssl://0.0.0.0:5671?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.enabledProtocols=TLSv1,TLSv1.1,TLSv1.2"/>
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="stomp+ssl" uri="stomp+ssl://0.0.0.0:61612?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.enabledProtocols=TLSv1,TLSv1.1,TLSv1.2"/>
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="mqtt+ssl" uri="mqtt+ssl://0.0.0.0:8883?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.enabledProtocols=TLSv1,TLSv1.1,TLSv1.2"/>

  Scenario: check transport configuration for enableClientAuth
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                        | value                                |
       | AMQ_TRANSPORTS                  | openwire,amqp,stomp,mqtt             |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR     | /opt/amq/conf                        |
       | AMQ_KEYSTORE                    | broker.ks                            |
       | AMQ_KEYSTORE_PASSWORD           | password                             |
       | AMQ_TRUSTSTORE                  | broker.ts                            |
       | AMQ_TRUSTSTORE_PASSWORD         | password                             |
       | AMQ_NEED_CLIENT_AUTH            | false                                |
    Then XML file /opt/amq/conf/activemq.xml should have 8 elements on XPath //amq:transportConnectors/amq:transportConnector
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="ssl" uri="ssl://0.0.0.0:61617?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.needClientAuth=false"/>
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="amqp+ssl" uri="amqp+ssl://0.0.0.0:5671?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.needClientAuth=false"/>
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="stomp+ssl" uri="stomp+ssl://0.0.0.0:61612?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.needClientAuth=false"/>
     And file /opt/amq/conf/activemq.xml should contain <transportConnector name="mqtt+ssl" uri="mqtt+ssl://0.0.0.0:8883?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600&amp;transport.needClientAuth=false"/>

  Scenario: check storage usage configuration
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                  | value           |
       | AMQ_STORAGE_USAGE_LIMIT   | 200 gb          |
    Then XML file /opt/amq/conf/activemq.xml should contain value 200 gb on XPath //amq:systemUsage/amq:storeUsage/amq:storeUsage/@limit

  Scenario: check authentication plugin configuration
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                  | value           |
       | AMQ_USER                  | openshift       |
       | AMQ_PASSWORD              | p4ssw0rd        |
    Then XML file /opt/amq/conf/activemq.xml should contain value activemq on XPath //amq:plugins/amq:jaasAuthenticationPlugin/@configuration

  Scenario: check authentication data configuration
    When container is started with env
       | variable                  | value           |
       | AMQ_USER                  | openshift       |
       | AMQ_PASSWORD              | p4ssw0rd        |
    Then file /opt/amq/conf/users.properties should contain openshift=p4ssw0rd

  Scenario: check mesh configuration
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                  | value           |
       | AMQ_MESH_SERVICE_NAME     | mymesh          |
       | AMQ_USER                  | openshift       |
       | AMQ_PASSWORD              | p4ssw0rd        |
    Then XML file /opt/amq/conf/activemq.xml should contain value dns://mymesh:61616/?transportType=tcp&queryInterval=30 on XPath //amq:networkConnectors/amq:networkConnector/@uri
    And XML file /opt/amq/conf/activemq.xml should contain value openshift on XPath //amq:networkConnectors/amq:networkConnector/@userName
    And XML file /opt/amq/conf/activemq.xml should contain value p4ssw0rd on XPath //amq:networkConnectors/amq:networkConnector/@password

  Scenario: check mesh configuration with custom mesh discovery protocol
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                | value  |
       | AMQ_MESH_SERVICE_NAME   | mymesh |
       | AMQ_MESH_DISCOVERY_TYPE | dummy  |
    Then XML file /opt/amq/conf/activemq.xml should contain value dummy://mymesh:61616/?transportType=tcp&queryInterval=30 on XPath //amq:networkConnectors/amq:networkConnector/@uri

  Scenario: check SSL configuration
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                    | value         |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf |
       | AMQ_KEYSTORE                | broker.ks     |
       | AMQ_KEYSTORE_PASSWORD       | password      |
       | AMQ_TRUSTSTORE              | broker.ts     |
       | AMQ_TRUSTSTORE_PASSWORD     | password      |
    Then XML file /opt/amq/conf/activemq.xml should contain value file:/opt/amq/conf/broker.ks on XPath //amq:sslContext/@keyStore
    And XML file /opt/amq/conf/activemq.xml should contain value password on XPath //amq:sslContext/@keyStorePassword
    And XML file /opt/amq/conf/activemq.xml should contain value file:/opt/amq/conf/broker.ts on XPath //amq:sslContext/@trustStore
    And XML file /opt/amq/conf/activemq.xml should contain value password on XPath //amq:sslContext/@trustStorePassword

  Scenario: check SSL configuration with missing keystore password
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                    | value         |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf |
       | AMQ_KEYSTORE                | broker.ks     |
       | AMQ_TRUSTSTORE              | broker.ts     |
       | AMQ_TRUSTSTORE_PASSWORD     | password      |
    Then XML file /opt/amq/conf/activemq.xml should have 0 elements on XPath //amq:sslContext
    AND container log should contain WARN Partial ssl configuration, the ssl context WILL NOT be configured.

  Scenario: check SSL configuration with missing truststore password
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                    | value         |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf |
       | AMQ_KEYSTORE                | broker.ks     |
       | AMQ_KEYSTORE_PASSWORD       | password      |
       | AMQ_TRUSTSTORE              | broker.ts     |
    Then XML file /opt/amq/conf/activemq.xml should have 0 elements on XPath //amq:sslContext
    AND container log should contain WARN Partial ssl configuration, the ssl context WILL NOT be configured.

  Scenario: check SSL configuration with missing keystore and truststore passwords
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                    | value         |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf |
       | AMQ_KEYSTORE                | broker.ks     |
       | AMQ_TRUSTSTORE              | broker.ts     |
    Then XML file /opt/amq/conf/activemq.xml should have 0 elements on XPath //amq:sslContext
    AND container log should contain WARN Partial ssl configuration, the ssl context WILL NOT be configured.

  Scenario: Check if jolokia is configured correctly
    When container is ready
    Then container log should contain -javaagent:/opt/jboss/container/jolokia/jolokia.jar=config=/opt/jboss/container/jolokia/etc/jolokia.properties

  # CLOUD-193
  Scenario: Check for dynamic resource allocation
    When container is started with args
      | arg                    | value             |
      | mem_limit              | 1073741824        |
    Then container log should contain -Xms128m -Xmx512m

  Scenario: Make sure we use the urandom
    When container is ready
    Then container log should contain -Djava.security.egd

  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And all files under /opt/amq are writeable by current user

  Scenario: CLOUD-865: check HTTP_PROXY gets converted to java proxy options
    When container is started with env
      | variable   | value                 |
      | HTTP_PROXY | http://localhost:1337 |
    Then container log should match regex .*JVM args:.*-Dhttp\.proxyHost=localhost -Dhttp\.proxyPort=1337.*

  # CLOUD-193 (mem-limit) & CLOUD-459
  # default heap size == max heap size == 1/2 available memory
  Scenario: Check for dynamic resource allocation
    When container is started with args
      | arg                    | value             |
      | mem_limit              | 1073741824        |
    Then container log should contain Heap sizes: current=125952k

  # CLOUD-459 (override default heap size)
  Scenario: Check for adjusted default heap size
    When container is started with args
      | arg       | value                        |
      | mem_limit | 1073741824                   |
      | env_json  | {"INITIAL_HEAP_PERCENT": 0.5} |
    Then container log should contain Heap sizes: current=251392k

  Scenario: Check if JAVA_OPTS_APPEND is being used
    When container is started with env
      | variable         | value     |
      | JAVA_OPTS_APPEND | -Dfoo=bar |
    Then container log should contain -Dfoo=bar

  Scenario: check mesh query interval is passed through to network connector URI
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                | value  |
       | AMQ_MESH_SERVICE_NAME   | mymesh |
       | AMQ_MESH_DISCOVERY_TYPE | dummy  |
       | AMQ_MESH_QUERY_INTERVAL | 60     |
    Then XML file /opt/amq/conf/activemq.xml should contain value dummy://mymesh:61616/?transportType=tcp&queryInterval=60 on XPath //amq:networkConnectors/amq:networkConnector/@uri

  Scenario: check nonHttpProxy escaping
    When container is started with env
       | variable                  | value           |
       | NO_PROXY                  | patriots.com    |
    Then container log should contain INFO | Apache ActiveMQ 5.11.0.redhat-
    And file /opt/amq/bin/env should contain -Dhttp.nonProxyHosts=patriots.com
  
  Scenario: check queue memory limit
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is started with env
       | variable                  | value           |
       | AMQ_QUEUES                | one,two,three   |
       | AMQ_QUEUE_MEMORY_LIMIT    | 2mb             |
    Then XML file /opt/amq/conf/activemq.xml should have 3 elements on XPath //amq:destinations/amq:queue
    And XML file /opt/amq/conf/activemq.xml should contain value 2mb on XPath //*[local-name()='policyEntry']/@memoryLimit

