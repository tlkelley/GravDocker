# GravDocker

Port 80 is exposed for web access. Nginx is configured to listen for all names.

### Volumes:
- /persist: Persistent app storage (internal use)
- /var/www/html: Grav site data

If deploying to Kubernetes, be sure to mount a PVC to /persist and any sort of persistent storage to /var/www/html
