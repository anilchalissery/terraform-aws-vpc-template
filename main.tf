provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA$$$$$$$$$$$$$$$$"
  secret_key = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
}

#VPC

resource "aws_vpc" "ProjName-env" {
  cidr_block       = "10.60.0.0/16"
  instance_tenancy = "default"
   enable_dns_hostnames = true
  tags = {
    Name = "ProjName-env"
  }
}


#IGW
resource "aws_internet_gateway" "ProjName-env" {
    vpc_id = "${aws_vpc.ProjName-env.id}"
    tags = {
    Name = "ProjName-env"
  }

}

#public subnets

resource "aws_subnet" "pub_net1_ProjName_env" {
  vpc_id            = "${aws_vpc.ProjName-env.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.60.0.0/24"
  tags {
        Name = "pub_net1_ProjName_env"
    }
}

resource "aws_subnet" "pub_net2_ProjName_env" {
  vpc_id            = "${aws_vpc.ProjName-env.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.60.5.0/24"
  tags {
        Name = "pub_net2_ProjName_env"
    }
}

#private subnets

resource "aws_subnet" "net1_ProjName_env" {
  vpc_id            = "${aws_vpc.ProjName-env.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.60.10.0/24"
  tags {
        Name = "net1_ProjName_env"
    }
}

resource "aws_subnet" "net2_ProjName_env" {
  vpc_id            = "${aws_vpc.ProjName-env.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.60.15.0/24"
  tags {
        Name = "net2_ProjName_env"
    }
}

#nat subnet


resource "aws_subnet" "nat_ProjName_env" {
  vpc_id            = "${aws_vpc.ProjName-env.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.60.20.0/24"
  tags {
        Name = "nat_ProjName_env"
    }
}

#nat gateway

resource "aws_eip" "ProjName-env" {
vpc      = true
tags {
        Name = "ProjName-env"
    }
}

resource "aws_nat_gateway" "ProjName-env" {
allocation_id = "${aws_eip.ProjName-env.id}"
subnet_id = "${aws_subnet.nat_ProjName_env.id}"
tags {
        Name = "ProjName_env"
    }
}


#route table for private subnet

resource "aws_route_table" "net_ProjName_env" {
  vpc_id = "${aws_vpc.ProjName-env.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ProjName-env.id}"
  }
 route {
	cidr_block = "Y.Y.Y.0/24"
	gateway_id = "${aws_vpn_gateway.ProjName-env.id}"

  }
 route {
        cidr_block = "Y.Y.Y.0/24"
        gateway_id = "${aws_vpn_gateway.ProjName-env.id}"

  }
  route {
        cidr_block = "Z.Z.Z.0/16"
        gateway_id = "${aws_vpn_gateway.ProjName-env.id}"

  }
  route {
        cidr_block = "Z.Z.Z.0/16"
        gateway_id = "${aws_vpn_gateway.ProjName-env.id}"

  }


  tags = {
    Name = "net_ProjName_env"
  }
}



#route table for public

resource "aws_route_table" "pub_net_ProjName_env" {
  vpc_id = "${aws_vpc.ProjName-env.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ProjName-env.id}"
  }
  tags = {
    Name = "pub_net_ProjName_env"
  }
}

#route table for nat-qa

resource "aws_route_table" "nat_ProjName_env" {
  vpc_id = "${aws_vpc.ProjName-env.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ProjName-env.id}"
  }
  tags = {
    Name = "nat_ProjName_env"
  }
}


#route table association of public subnets

resource "aws_route_table_association" "pub_net1_ProjName_env" {
  subnet_id      = "${aws_subnet.pub_net1_ProjName_env.id}"
  route_table_id = "${aws_route_table.pub_net_ProjName_env.id}"
}

resource "aws_route_table_association" "pub_net2_ProjName_env" {
  subnet_id      = "${aws_subnet.pub_net2_ProjName_env.id}"
  route_table_id = "${aws_route_table.pub_net_ProjName_env.id}"
}

#route table association of private subnets

resource "aws_route_table_association" "net1_ProjName_env" {
  subnet_id      = "${aws_subnet.net1_ProjName_env.id}"
  route_table_id = "${aws_route_table.net_ProjName_env.id}"
}

resource "aws_route_table_association" "net2_ProjName_env" {
  subnet_id      = "${aws_subnet.net2_ProjName_env.id}"
  route_table_id = "${aws_route_table.net_ProjName_env.id}"
}

#route table association of nat subnet

resource "aws_route_table_association" "nat_ProjName_env" {
  subnet_id      = "${aws_subnet.nat_ProjName_env.id}"
  route_table_id = "${aws_route_table.nat_ProjName_env.id}"
}




#virtual private gateway

resource "aws_vpn_gateway" "ProjName-env" {
  vpc_id = "${aws_vpc.ProjName-env.id}"

  tags = {
    Name = "ProjName-env"
  }
}

#Customer-gateway Add your public ip in ip_address without subnet

resource "aws_customer_gateway" "My-office-ip" {
  bgp_asn    = 65000
  ip_address = "X.X.X.X"
  type       = "ipsec.1"
  tags = {
    Name = "My-office-ip"
  }
}

# site to site connection

resource "aws_vpn_connection" "ProjName-env-ServiceProvider" {
  customer_gateway_id = "${aws_customer_gateway.My-office-ip.id}"
  vpn_gateway_id      = "${aws_vpn_gateway.ProjName-env.id}"
  type                = "${aws_customer_gateway.My-office-ip.type}"
  static_routes_only  = true
  tags = {
    Name = "ProjName-env-ServiceProvider"
  }
}

resource "aws_vpn_connection_route" "ServiceProvider" {
  destination_cidr_block = "Z.Z.Z.0/16"
  vpn_connection_id      = "${aws_vpn_connection.ProjName-env-ServiceProvider.id}"
}

resource "aws_vpn_connection_route" "ServiceProvider_ssl" {
  destination_cidr_block = "Y.Y.Y.0/24"
  vpn_connection_id      = "${aws_vpn_connection.ProjName-env-ServiceProvider.id}"
}


