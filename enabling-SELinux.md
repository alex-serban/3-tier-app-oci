**Re-enabling SELinux**

```bash
sudo setenforce 0
/etc/selinux/config - SELINUX=disabled
```

**Changing the context for my files***

```bash
sudo chcon -t httpd_sys_script_exec_t /var/www/html/index.sh
sudo semanage fcontext -a -t httpd_sys_script_exec_t "/var/www/html/*"
```
