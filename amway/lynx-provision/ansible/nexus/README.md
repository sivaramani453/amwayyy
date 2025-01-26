# Quick run

* <pre>ansible-galaxy install -r requirements.yml -p ../roles/</pre>
* In ../roles/ansible-thoteam.nexus3/tasks/nexus_install.yml, replace this part of code:

<pre>
- name: Upload new scripts
  unarchive:
    src: "/tmp/nexus-upload-groovy-scripts.tar.gz"
    dest: "{{ nexus_data_dir }}/groovy-raw-scripts/new/"
    mode: 0644
</pre>

with following code:

<pre>
- name: Upload new scripts
  copy:
    src: "/tmp/nexus-upload-groovy-scripts.tar.gz"
    dest: "{{ nexus_data_dir }}/groovy-raw-scripts/new.tgz"

- name: Upload new scripts
  unarchive:
    remote_src: yes
    src: "{{ nexus_data_dir }}/groovy-raw-scripts/new.tgz"
    dest: "{{ nexus_data_dir }}/groovy-raw-scripts/new/"
    mode: 0644
</pre>

* On the top folder: <pre>packer run nexus.json</pre>

You should get the job done with above.

# Problems I've experienced when working with Nexus

* It does not want to unarchive files on AWS

I performed tests on my local ProxMox server, but when I switched to AWS, instead of expected success, I experienced crash in thoteam nexus3 role. It was unable to unarchive files on AWS target. Quick googling shown that it is probably due to buddy file upload, or something like this. There arre two options: run the packer command on a VM which is already on AWS, or slightly modify thoteam role:

In main ansible-thoteam.nexus role dir, in nexus_install.yml, replace this part of code:

<pre>
- name: Upload new scripts
  unarchive:
    src: "/tmp/nexus-upload-groovy-scripts.tar.gz"
    dest: "{{ nexus_data_dir }}/groovy-raw-scripts/new/"
    mode: 0644
</pre>

with following code:

<pre>
- name: Upload new scripts
  copy:
    src: "/tmp/nexus-upload-groovy-scripts.tar.gz"
    dest: "{{ nexus_data_dir }}/groovy-raw-scripts/new.tgz"

- name: Upload new scripts
  unarchive:
    remote_src: yes
    src: "{{ nexus_data_dir }}/groovy-raw-scripts/new.tgz"
    dest: "{{ nexus_data_dir }}/groovy-raw-scripts/new/"
    mode: 0644
</pre>

* Problems with Java installation

The Java version required by Nexus 3 is exactly 1.8. I couldnt install it with lean delivery Java role at first, so I tried Geerlingguy role for it, and it worked. After resolving other issues, I searched the iac codebase, and I've found how it can be done. The solution in this playbook implements lean delivery role with parameters I've found, and it works as well.

* Problems with non-empty password requirement for anonymous access

For purpose of user-to-roles assignment the Nexus role uses code that requires all user data, ie email, first and last name, and password, to be provided. Providing password for anonymous access seems to be weird, but as I checked, this password is being completely ignored by nexus. It works well, no need to enter password anywhere. The other option is to write Groovy script that does it with another piece of code, thus not requiring password at all, only login and desired groups.
