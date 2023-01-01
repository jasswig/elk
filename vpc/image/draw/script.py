from diagrams import Cluster, Diagram, Edge
import diagrams.aws.network as network
import diagrams.aws.general as general
import diagrams.aws.compute as compute
import diagrams.aws.management as management

def vpc():
    with Diagram("Custom VPC", show=False):
        
        with Cluster("MyVPC 10.0.0.0/16"):
            prt = general.InternetGateway("MyIGW") >> Edge(color="black") << network.RouteTable("Public-RT")
            
            
            with Cluster("use1-az1"):
                ntga = network.NATGateway("MyNatG-a")
                compute.EC2ElasticIpAddress("MyEIP-a") << ntga >> Edge(color="brown") << network.PublicSubnet("Public-1A 10.0.1.0/24") >> prt 
                network.PrivateSubnet("Private-1A 10.0.3.0/24") >> network.RouteTable("Private-RT-a") >> Edge(label="egress") << ntga
            with Cluster("use1-az2"):
                ntgb = network.NATGateway("MyNatG-b") 
                compute.EC2ElasticIpAddress("MyEIP-b") << ntgb >> Edge(color="brown") << network.PublicSubnet("Public-1B 10.0.2.0/24") >> prt
                network.PrivateSubnet("Private-1B 10.0.4.0/24") >> network.RouteTable("Private-RT-b") >> Edge(label="egress") << ntgb
            

def stack():
    with Diagram("ELK AWS", show=False): 
        cw = management.Cloudwatch("Log groups")       
        with Cluster("MyVPC 10.0.0.0/16"): 
            kibana = compute.EC2Instance("Kibana") >> cw
            with Cluster("Private"):
                compute.EC2Instance("App + Filebeat") >> cw
                compute.EC2Instance("Logstash") >> cw
                compute.EC2Instance("Elasticsearch") >> cw

            
                


vpc()
stack()
                    