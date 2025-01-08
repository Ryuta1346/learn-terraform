# public_alb_sg_vars = {
#   ingress_rules = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "TCP"
#       cidr_blocks = "0.0.0.0/0"
#       description = "Allow HTTP traffic from anywhere"
#     },
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "TCP"
#       cidr_blocks = "0.0.0.0/0"
#       description = "Allow HTTPS traffic from anywhere"
#     }
#   ],
#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Allow all outbound traffic"
#     }
#   ]
# }

# private_sg_vars = {
#   ingress_rules = [
#     {
#       from_port = 443
#       to_port   = 443
#       protocol  = "tcp"
#     },
#     {
#       from_port = 80
#       to_port   = 80
#       protocol  = "tcp"
#     }
#   ]
#   egress_rules = [
#     {
#       from_port   = -1
#       to_port     = -1
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   ]
# }
