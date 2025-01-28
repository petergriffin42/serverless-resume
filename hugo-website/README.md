https://gohugo.io/installation/linux/

Updating the resume content requires having Hugo installed. Then run the following to create a Dev version locally of the content.

hugo server -D hugo server --disableFastRender

Once complete run the following and it will template out the data into the public directory. Terraform will take that data and upload it.

hugo --minify