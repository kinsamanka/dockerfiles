# Minimal Alpine-based Motion+MotionEye Image

Usage
-----

```bash
docker run -d --name motioneye \
	–p 80:8765 \
	-v ${data_dir}:/data \
	kinsamanka/motioneye
```

Access MotionEye through: 
```
http://your-ip-here
```
