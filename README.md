# Satel Registry Push
This centralized GitHub action pushes a docker image to registry 

## Usage 
```yml
name: "Push to docker image to registry"
on:
  push:
    branches:
      - main  
deploy-to-qa:
    name: Registry push
    needs: [generate-variables, build-client, build-server]
    if: github.ref == 'refs/heads/main' # run only on main
    runs-on: <host_name>
    steps:
      - name: Push client image to registry
        id: registry-push
        uses: SatelCreative/satel-registry-push@feature/webapp-deployment-shell
        with:
          app-name: <app-name>
          satel-docker-user: ${{ secrets.SATEL_DOCKER_USER }}
          satel-docker-pass: ${{ secrets.SATEL_DOCKER_PASS }}
          client-docker-user: ${{ secrets.CLIENT_DOCKER_USER }}
          client-docker-pass: ${{ secrets.CLIENT_DOCKER_PASS }}
          satel-registry: docker.satel.ca
          client-registry: sb-docker.satel.ca
          dockerfile: <Dockerfile>
          current-branch-name: ${{needs.generate-variables.outputs.branch-name}}
          tag-name: ${{needs.generate-variables.outputs.tag-name}}  
```

 - `host_name` is `self-hosted` or the name of server where the action runner is hosted, `cosmicray` for example
 - `app-name` can be `st-pim` or `sb-pim` for example
 - `clean-branch-name` & `tag-name` parameters are set in a previous step  
 - `satel & client docker-user` & `satel & client docker-pass` are secrets added from the settings.           