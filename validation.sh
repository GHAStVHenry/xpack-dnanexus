APP_ID=$1
echo "==== NEXTFLOW-DX VALIDATION SUITE ===="

##
## check license file
##
if dx run $APP_ID --watch -y \
  --input license=project-G59Yx080Py3x24b94ZbKGKKY:/xpack-license.txt \
  --input args="-with-docker" \
  >validate-01-should-run-with-license.txt 2>&1; then
  echo -e "\xE2\x9C\x94 Check PASS: should run with license file"
else
  echo -e "\xE2\x9D\x8C Check FAIL: should run with license file"
fi

if dx run $APP_ID --watch -y \
  >validate-02-should-not-run-without-license.txt 2>&1; then
  echo -e "\xE2\x9D\x8C Check FAIL: should not run without license file"
else
  echo -e "\xE2\x9C\x94 Check PASS: should not run without license file"
fi

#
# check private GH repo
#
if dx run $APP_ID --watch -y \
  --input pipeline_url=https://github.com/seqeralabs/nf-sleep-for-dx-testing \
  --input license=project-G59Yx080Py3x24b94ZbKGKKY:/xpack-license.txt \
  --input scm_file=project-G59Yx080Py3x24b94ZbKGKKY:/scm.txt \
  >validate-03-should-run-with-scm-file.txt 2>&1; then
  echo -e "\xE2\x9C\x94 Check PASS: should run using a private GitHub repository"
else
  echo -e "\xE2\x9D\x8C Check FAIL: should run using a private GitHub repository"
fi

if dx run $APP_ID --watch -y \
  --input pipeline_url=https://github.com/seqeralabs/nf-sleep-for-dx-testing \
  --input license=project-G59Yx080Py3x24b94ZbKGKKY:/xpack-license.txt \
  >validate-04-should-not-run-without-scm-file.txt.txt 2>&1; then
  echo -e "\xE2\x9D\x8C Check FAIL: should not run without SCM file"
else
  echo -e "\xE2\x9C\x94 Check PASS: should not run without SCM file"
fi

##
## check private docker registry
##
if dx run $APP_ID --watch -y \
  --input license=project-G59Yx080Py3x24b94ZbKGKKY:/xpack-license.txt \
  --input args="-with-docker pditommaso/rnaseq-test:v1.0" \
  --input docker_creds_file=project-G59Yx080Py3x24b94ZbKGKKY:/docker-creds.json \
  >validate-05-should-run-with-docker-creds-file.txt 2>&1; then
  echo -e "\xE2\x9C\x94 Check PASS: should run using Docker credentials file"
else
  echo -e "\xE2\x9D\x8C Check FAIL: should run using Docker credentials file"
fi

#if dx run $APP_ID --watch -y \
#  --input license=project-G59Yx080Py3x24b94ZbKGKKY:/xpack-license.txt \
#  --input args="-with-docker pditommaso/rnaseq-test:v1.0" \
#  >validate-06-should-not-run-without-docker-#creds-file.txt 2>&1; then
#  echo -e "\xE2\x9D\x8C Check FAIL: should not run without Docker credentials file"
#else
#  echo -e "\xE2\x9C\x94 Check PASS: should not run without Docker credentials file"
#fi
