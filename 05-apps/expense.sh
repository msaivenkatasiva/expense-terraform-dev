#!/bin/bash
#userdata bydefault gets sudo access

dnf install ansible -y
cd /tmp
git clone https://github.com/msaivenkatasiva/expense_ansible_roles.git
cd expense_ansible_roles
ansible-playbook main.yaml -e component=backend -e login_password=ExpenseApp1
ansible-playbook main.yaml -e component=frontend