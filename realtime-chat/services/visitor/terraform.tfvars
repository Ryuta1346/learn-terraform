# public_alb_sg_vars = [
#   {
#     security_group_name = "visitor-chat-public"
#     vpc_id              = module.vpc.vpc_id
#     description         = "Security group for the visitor-chat public ALB"
#     ingress_rules = [
#       {
#         from_port   = 80
#         to_port     = 80
#         protocol    = "TCP"
#         cidr_blocks = "0.0.0.0/0"
#         description = "Allow HTTP traffic from anywhere"
#       },
#       {
#         from_port   = 443
#         to_port     = 443
#         protocol    = "TCP"
#         cidr_blocks = "0.0.0.0/0"
#         description = "Allow HTTPS traffic from anywhere"
#       }
#     ],
#     egress_rules = [
#       {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#         description = "Allow all outbound traffic"
#       }
#     ]
#   }
# ]