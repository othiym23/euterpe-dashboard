DELETE
  FROM albums
 WHERE id IN (SELECT DISTINCT albums.id
                FROM albums,
                     discs,
                     tracks,
                     media_paths
               WHERE albums.id = discs.album_id
                 AND discs.id = tracks.disc_id
                 AND tracks.media_path_id = media_paths.id
                 AND media_paths.file_updated_on > DATE '2006-05-23');

DELETE
  FROM discs
 WHERE id IN (SELECT DISTINCT discs.id
                FROM discs,
                     tracks,
                     media_paths
               WHERE discs.id = tracks.disc_id
                 AND tracks.media_path_id = media_paths.id
                 AND media_paths.file_updated_on > DATE '2006-05-23');

DELETE
  FROM tracks
 WHERE id IN (SELECT DISTINCT tracks.id
                FROM tracks,
                     media_paths
               WHERE tracks.media_path_id = media_paths.id
                 AND media_paths.file_updated_on > DATE '2006-05-23');

DELETE
  FROM media_paths
 WHERE file_updated_on > DATE '2006-05-23';

DELETE
  FROM disc_buckets
 WHERE file_updated_on > DATE '2006-05-23';
