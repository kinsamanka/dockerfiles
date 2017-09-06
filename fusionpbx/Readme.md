![alt text][logo]
[logo]: https://raw.githubusercontent.com/fusionpbx/fusionpbx-docs/master/source/_static/images/logo.png "FusionPBX Logo"


# Minimal Alpine-based FusionPBX Image

Usage
-----

```bash
docker run -d --name fusionpbx \
	–net=host \
	-v /etc/localtime:/etc/localtime:ro \
	-v ${data_dir}:/data \
	-e PGPASSWORD=${postgres_pass} \
	kinsamanka/fusionpbx 
```
Access FusionPBX through: 
```
http://your-ip-here
```


