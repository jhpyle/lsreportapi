# lsreportapi

This is a web service API to the Legal Server reporting mechanism.
Given login credentials and a report ID number, the API returns the
content of the report in JSON format.  This can be used to integrate
other software with Legal Server.

The API uses [CasperJS](http://casperjs.org/) to scrape the contents
of a Legal Server report from the front end of Legal Server.  The code
goes to the URL of the report (e.g.,
`http://pla.legalserver.org/report/dynamic?load=360`), logs in,
selects "View All", and then extracts the contents of the report from
the HTML table.

## Invocation

You call it by sending a GET or POST request to the server.  E.g.:

    curl -o output.json --data "s=pla&u=jpyle&p=secr3tPass&r=360" https://ls.docassemble.org/

where:

* `-o output.json` means that output should be stored in a file called `output.json`
* `s=pla` means that the server to use should be `https://pla.legalserver.org`.
* `u=jpyle` means that the user to log in as should be `jpyle`.
* `p=secr3tPass` means that the user's password is `secr3tPass`.
* `r=360` means that the report to run is the report with ID
  number `360`.  You can find the report number of a report by
  inspecting the hyperlink shown in your browser when you hover over a
  link to the given report.

## Output

The output will look something like this:

    {
        "rows": [
            {
                "Age at Intake": "65",
                "Citizenship Status": "Citizen",
                "City": "Philadelphia",
                "Date of Earliest(Open, Intake, Prescreen)": "2016-03-14",
                "Disabled": "Yes",
                "Zip Code": "19143"
            },
            {
                "Age at Intake": "44",
                "Citizenship Status": "Citizen",
                "City": "Philadelphia",
                "Date of Earliest(Open, Intake, Prescreen)": "2016-03-11",
                "Disabled": "No",
                "Zip Code": "19124"
            }
        ],
        "result": "success"
    }

The `result` key will be set to `success` unless an error occurs, in
which case the `result` will contain an error message.

It is also possible that the entire output will be blank, which
indicates that an error occurred.

## Security

Since a Legal Server password is transmitted to the API, it is
important to take measures to protect the security of your Legal
Server instance.

* If you test the API by using a web browser to send a GET request,
delete your browser history afterward.  Otherwise the password will be
stored in the browser history.
* Note that if you use the command line, and your password is part of
the command, the password may become available to other users through
the `w` command.  It is best to write a script that uses a library to
form HTTP requests.
* The user in Legal Server should be a special user with a special
role that has very limited privileges.  Only give this role the
privilege of running specific reports that you want to make available
through the API.
* Note that the user can only have one Legal Server session open at a
time.  If you are logged in as yourself and then you use the API with
your own Legal Server user name, the API will log you out of your
initial session.
* Sending passwords over HTTP is insecure, so you should never deploy
this API without using HTTPS.  To facilitate use of HTTPS, this API's
standard installation procedure uses Let's Encrypt to obtain SSL
certificates for you.

## Installation

The easiest way to install this API on a server is to use Docker on
Amazon Web Services.

Create an Amazon EC2 instance running Amazon Linux, and give it a
security group that opens ports 22, 80, and 443 to the outside world.
Note the URL of the server, go to your DNS provider, and create a
CNAME record that points to the server.

For example, the CNAME record might map `ls.my-organization.org` to
`ec2-54-159-24-192.compute-1.amazonaws.com`.

Then connect to the server using ssh and run the following from the
command line:

Run:

    sudo yum -y update
    sudo yum -y install docker git
    sudo usermod -a -G docker ec2-user

Then log off and ssh back into the instance again.  (This effectuates
the `usermod` command, allowing the default user `ec2-user` to gain
permission to run Docker).

Then do:

    docker run \
    --env HOSTNAME=ls.docassemble.org \
    --env LETSENCRYPTEMAIL=jhpyle@gmail.com \
    --volume lraletsencrypt:/etc/letsencrypt \
    --volume lraapache:/etc/apache2/sites-available \
    --detach --publish 80:80 --publish 443:443 jhpyle/lsreportapi

where you have first edited the `HOSTNAME` to be the hostname whose
DNS you set up, and where you have edited `LETSENCRYPTEMAIL` to
be the e-mail address you want to use to access Let's Encrypt.

This will create a Docker container that runs Debian Linux,
supervisord, apache2, letsencrypt, and the API.

Note that no other web servers can run on the machine (i.e. ports 80
and 443 need to be available).  The EC2 instance will pass through
traffic on ports 80 and 443 to the Docker container.

## How to upgrade

To upgrade to a newer version of the API, `stop` and `rm` the running
Docker container, then run:

    docker pull jhpyle/lsreportapi

This will retrieve the latest version of the code from Docker Hub.
(The Docker image is based off of the "master" branch of this GitHub
repository.  Docker Hub "auto-builds" the new Docker image whenever
a new commit in the "master" branch is pushed to GitHub.)

Then, re-run the same `docker run` command that you ran to deploy the
API in the first place.  You can actually leave out the environment
variables because the Docker volumes will retain your Let's Encrypt
certificates and the web server configuration.  So this command line
would be enough to deploy the API:

    docker run \
    --volume lraletsencrypt:/etc/letsencrypt \
    --volume lraapache:/etc/apache2/sites-available \
    --detach --publish 80:80 --publish 443:443 jhpyle/lsreportapi

## Contact the developer

If you have questions, contact Jonathan Pyle at jhpyle@gmail.com.
