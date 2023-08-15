FROM centos:centos7

# Update currently installed package and install httpd package
RUN yum -y update && yum -y install httpd

COPY httpd.conf /etc/httpd/conf/

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]
