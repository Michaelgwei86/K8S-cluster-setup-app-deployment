resource "aws_vpc" "effulgencetech-dev-vpc"{
      cidr_block = "10.0.0.0/16"

  tags = {
    Name = "effulgencetech-dev-vpc"
  }
}

resource "aws_internet_gateway" "effulgencetech-dev-igw" {
  vpc_id = aws_vpc.effulgencetech-dev-vpc.id

  tags = {
    Name = "effulgencetech-dev-igw"
  }
}

resource "aws_subnet" "effulgencetech-dev-private-subnet-1" {
  vpc_id            = aws_vpc.effulgencetech-dev-vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-west-2a"

  tags = {
    "Name"                            = "effulgencetech-dev-private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "effulgencetech-dev-private-subnet-2" {
  vpc_id            = aws_vpc.effulgencetech-dev-vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-west-2b"

  tags = {
    "Name"                            = "effulgencetech-dev-private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "effulgencetech-dev-public-subnet-1" {
  vpc_id                  = aws_vpc.effulgencetech-dev-vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "effulgencetech-dev-public-subnet-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_subnet" "effulgencetech-dev-public-subnet-2" {
  vpc_id                  = aws_vpc.effulgencetech-dev-vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "effulgencetech-dev-public-subnet-2"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_eip" "effulgencetech-dev-eip" {
  vpc = true

  tags = {
    Name = "effulgencetech-dev-nat"
  }
}

resource "aws_nat_gateway" "effulgencetech-dev-nat-gw" {
  allocation_id = aws_eip.effulgencetech-dev-eip.id
  subnet_id     = aws_subnet.effulgencetech-dev-public-subnet-1.id

  tags = {
    Name = "effulgencetech-dev-nat-gw"
  }

  depends_on = [aws_internet_gateway.effulgencetech-dev-igw]
}

resource "aws_route_table" "effulgencetech-dev-private-rtb" {
  vpc_id = aws_vpc.effulgencetech-dev-vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.effulgencetech-dev-nat-gw.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "effulgencetech-dev-private-rtb"
  }
}

resource "aws_route_table" "effulgencetech-dev-public-rtb" {
  vpc_id = aws_vpc.effulgencetech-dev-vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.effulgencetech-dev-igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "effulgencetech-dev-public-rtb"
  }
}

resource "aws_route_table_association" "effulgencetech-dev-private-rtb-ass-1" {
  subnet_id      = aws_subnet.effulgencetech-dev-private-subnet-1.id
  route_table_id = aws_route_table.effulgencetech-dev-private-rtb.id
}

resource "aws_route_table_association" "effulgencetech-dev-private-rtb-ass-2" {
  subnet_id      = aws_subnet.effulgencetech-dev-private-subnet-2.id
  route_table_id = aws_route_table.effulgencetech-dev-private-rtb.id
}

resource "aws_route_table_association" "effulgencetech-dev-public-rtb-ass-1" {
  subnet_id      = aws_subnet.effulgencetech-dev-public-subnet-1.id
  route_table_id = aws_route_table.effulgencetech-dev-public-rtb.id
}

resource "aws_route_table_association" "effulgencetech-dev-public-rtb-ass-2" {
  subnet_id      = aws_subnet.effulgencetech-dev-public-subnet-2.id
  route_table_id = aws_route_table.effulgencetech-dev-public-rtb.id
}