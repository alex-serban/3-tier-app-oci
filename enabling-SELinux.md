**Re-enabling SELinux**

```bash
sudo setenforce 1
/etc/selinux/config - SELINUX=enforce
```

**Changing the context for my files***

```bash
sudo chcon -t httpd_sys_script_exec_t /var/www/html/index.sh
sudo semanage fcontext -a -t httpd_sys_script_exec_t "/var/www/html/*"
```
