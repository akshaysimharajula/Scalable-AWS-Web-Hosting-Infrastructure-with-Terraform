module "vpc" {
  source = "./vpc"
}

module "ec2" {
  source     = "./ec2"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  my_sg_out  = module.vpc.my_sg_out
}


module "ASG" {
  source             = "./asg"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  my_sg_out          = module.vpc.my_sg_out
  webserver_template = module.ec2.webserver_template
}
