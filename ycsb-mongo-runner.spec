%define __jar_repack %{nil}
%define run_user nobody

Name:		ycsb-mongo-runner
Version:	%{version}
Release:	1%{?dist}
Summary:	ycsb-mongo-runner

Group:		Software/Databases
License:	Apache 2.0
URL:		https://github.com/Percona-Lab/ycsb-mongo-runner
Source0:	https://github.com/brianfrankcooper/YCSB/releases/download/%{version}/ycsb-%{version}.tar.gz
Source1:	bench.sh
Source2:	bench-workload.sh
Source3:	deleter.js
Source4:	setup-auth.js
Prefix:		/opt
BuildArch:	noarch

Requires:	java-1.8.0-openjdk

%description
ycsb-mongo-runner


%prep
%setup -q -n ycsb-%{version}

# remove all *-binding dirs that are not mongodb-binding
find -mindepth 1 -maxdepth 1 -type d -name "*-binding" ! -name "mongodb-binding" | xargs rm -rf


%install
mkdir -p %{buildroot}%{prefix}/%{name} %{buildroot}/etc/sysconfig %{buildroot}/etc/systemd/system

cp -dpR %{_builddir}/ycsb-%{version} %{buildroot}%{prefix}/%{name}
pushd %{buildroot}%{prefix}/%{name}
ln -nfs ycsb-%{version} ycsb
popd

install -m 0755 %{SOURCE1} %{buildroot}%{prefix}/%{name}
install -m 0755 %{SOURCE2} %{buildroot}%{prefix}/%{name}
install -m 0644 %{SOURCE3} %{buildroot}%{prefix}/%{name}
install -m 0644 %{SOURCE4} %{buildroot}%{prefix}/%{name}


%{__cat} <<EOF >>%{buildroot}/etc/systemd/system/%{name}.service
[Unit]
Description=%{name}
After=time-sync.target network.target

[Service]
Type=forking
User=%{run_user}
Group=root
PermissionsStartOnly=true
EnvironmentFile=-/etc/sysconfig/%{name}
ExecStart=/usr/bin/env bash -c "%{prefix}/%{name}/bench.sh >/dev/null & echo \$! >%{prefix}/%{name}/tmp/%{name}.pid; disown \$!"
PIDFile=%{prefix}/%{name}/tmp/%{name}.pid
Restart=always
RestartSec=10
EOF

%{__cat} <<EOF >>%{buildroot}/etc/sysconfig/%{name}
MONGO_URL_PREFIX=mongodb://localhost:27017
#MONGODB_URL_PREFIX=mongodb://username:password@localhost:27029
EOF


%post
/usr/bin/systemctl daemon-reload

if [ $1 == 1 ]; then
  if [ ! -d %{prefix}/%{name}/log ]; then
    mkdir -p %{prefix}/%{name}/log
    chown -R %{run_user} %{prefix}/%{name}/log
  fi
  if [ ! -d %{prefix}/%{name}/tmp ]; then
    mkdir -p %{prefix}/%{name}/tmp
    chown -R %{run_user} %{prefix}/%{name}/tmp
  fi
fi


%preun
if [ $1 == 0 ]; then
  /usr/bin/systemctl stop %{name}
fi


%postun
/usr/bin/systemctl daemon-reload

if [ $1 == 0 ]; then
  rm -rf %{prefix}/%{name}/tmp
fi


%files
%config(noreplace) /etc/sysconfig/%{name}
/etc/systemd/system/%{name}.service
%{prefix}/%{name}/*.sh
%{prefix}/%{name}/*.js
%{prefix}/%{name}/ycsb
%{prefix}/%{name}/ycsb-%{version}



%changelog

