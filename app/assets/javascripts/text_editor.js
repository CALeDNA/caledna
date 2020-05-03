//= require bootstrap-sprockets
//= require summernote/summernote-bs4.min

(function () {
  const sendFile = function (file, toSummernote) {
    var data;
    data = new FormData();
    data.append("upload[image]", file);

    $.ajaxSetup({
      headers: { "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content") },
    });

    return $.ajax({
      data: data,
      type: "POST",
      url: "/uploads",
      cache: false,
      contentType: false,
      processData: false,
      success: function (data) {
        console.log("file uploading...");
        if (typeof data.errors !== "undefined" && data.errors !== null) {
          console.log("ops! errors...", data.errors);
        } else {
          console.log("inserting image in to editor...", data.url);
          return toSummernote.summernote("insertImage", data.url, ($image) => {
            $image.attr("data-id", data.id);
          });
        }
      },
    });
  };

  const deleteFile = function (file_id) {
    return $.ajax({
      type: "DELETE",
      url: "/uploads/" + file_id,
      cache: false,
      contentType: false,
      processData: false,
    });
  };

  Array.prototype.diff = function (a) {
    return this.filter(function (i) {
      return a.indexOf(i) < 0;
    });
  };

  $(function () {
    return $('[data-provider="summernote"]').each(function () {
      return $(this).summernote({
        toolbar: [
          [
            "styles",
            [
              "style",
              "bold",
              "italic",
              "underline",
              "superscript",
              "subscript",
              "clear",
            ],
          ],
          ["blocks", ["ul", "ol", "paragraph", "hr"]],
          ["insert", ["link", "picture", "video"]],
          ["misc", ["fullscreen", "codeview", "help"]],
        ],
        lang: "ko-KR",
        height: 400,
        callbacks: {
          onInit: function () {
            console.log("Summernote is launched");
            return (this.oldValue = this.value);
          },
          onImageUpload: function (files, e) {
            console.log("Files were uploaded: ");
            console.log(files);
            return sendFile(files[0], $(this));
          },
          onMediaDelete: function (target, editor, editable) {
            var upload_id = target.attr("data-id");
            console.log("File was deleted : " + upload_id);

            if (!!upload_id) {
              deleteFile(upload_id);
              this.oldValue = $(".note-editable.card-block")[0].innerHTML;
            }
            return target.remove();
          },
          onKeyup: function (e) {
            var deletedImage,
              deletedImages,
              matches,
              myRegexp,
              newImages,
              newValue,
              oldImages,
              _i,
              _len,
              _results;
            if (e.keyCode === 8 || e.keyCode === 46) {
              newValue = e.target.innerHTML;
              oldImages = this.oldValue.match(/<img\s(?:.+?)>/g);
              oldImages = oldImages ? oldImages : [];
              newImages = newValue.match(/<img\s(?:.+?)>/g);
              newImages = newImages ? newImages : [];
              this.oldValue = newValue;
              deletedImages = newImages ? oldImages.diff(newImages) : [];
              if (deletedImages.length > 0) {
                _results = [];
                for (_i = 0, _len = deletedImages.length; _i < _len; _i++) {
                  deletedImage = deletedImages[_i];
                  myRegexp = /data-id="(\d+)"/g;
                  matches = myRegexp.exec(deletedImage);
                  if (
                    confirm(
                      "Are you sure?\nYou can't revert if images have been deleted."
                    )
                  ) {
                    deleteFile(matches[1]);
                    _results.push(
                      console.log(
                        "* Permanently removed : " +
                          matches[1] +
                          ": " +
                          matches[2]
                      )
                    );
                  } else {
                    _results.push(void 0);
                  }
                }
                return _results;
              }
            }
          },
        },
      });
    });
  });
}.call(this));
