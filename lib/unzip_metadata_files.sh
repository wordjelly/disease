for f in /home/bhargav/Github/disease/vendor/pubmed_metadata_files/*.gz; do
  STEM=$(basename "${f}" .gz)
  echo $STEM
  gunzip -c "${f}" > /home/bhargav/Github/disease/vendor/pubmed_metadata_unzipped/"${STEM}"
done