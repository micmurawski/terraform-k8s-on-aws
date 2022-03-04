resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.flow_logs ? 1 : 0
  tags  = local.tags
  name  = format("%s-vpc-flow-logs-role", var.prefix)

  assume_role_policy = jsonencode(
    {
      "Version" = "2012-10-17",
      "Statement" = [
        {
          "Sid"    = "",
          "Effect" = "Allow",
          "Principal" = {
            "Service" = "vpc-flow-logs.amazonaws.com"
          },
          "Action" = "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  count = var.flow_logs ? 1 : 0
  name  = format("%s-vpc-flow-logs-policy", var.prefix)
  role  = aws_iam_role.vpc_flow_logs_role[count.index].id

  policy = jsonencode(
    {
      "Version" = "2012-10-17",
      "Statement" = [
        {
          "Action" = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ],
          "Effect"   = "Allow",
          "Resource" = "*"
        }
      ]
    }
  )
}
