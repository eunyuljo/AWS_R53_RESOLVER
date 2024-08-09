resource "aws_vpc_dhcp_options" "vpc2_dhcp_options" {
  domain_name         = "idcneta.internal"
  domain_name_servers = ["10.80.1.200", "8.8.8.8"]
  ntp_servers         = ["203.248.240.140", "168.126.63.1"]
  tags = {
    Name = "IDC-VPC2-DHCPOptions"
  }
}
# VPC2에 DHCP 옵션 세트 연결
resource "aws_vpc_dhcp_options_association" "vpc2_dhcp_options_association" {
  vpc_id          = aws_vpc.vpc2.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc2_dhcp_options.id
}