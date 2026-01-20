# kubernetes-dashboard-tall-namespace
I got sick and tired of a namespace dropdown that maxes out at 256px tall.<br />
So I made it calc(100% - 40px) tall.<br />
It's the exact same Kubernetes Dashboard... but the namespace dropdown isn't tiny.<br />
<hr>
Just follow the standard procedure for installation of the kubernetes dashboard, except substitute the web image for this one.

```
--set web.image.repository=docker.io/library/kubernetes-dashboard-tall-namespace
```
The above presumes you built it yourself. Once I have started pushing this to registries, I will change this as necessary.
