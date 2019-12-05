var send2S3 = function (file, data, callback) {
    if (!file) {
      return
    }

    let url = data.s3endpoint
    let fields = JSON.parse(data.fields)

    var XHR = new XMLHttpRequest();
    var FD  = new FormData();

    // 如果限制了key的格式，直接用文件名替换占位符
    fields['key'] = (fields['key'] || '').replace('${filename}', file.name)

    for(key in fields) {
      FD.append(key, fields[key])
    }

    // 如果没有限制明确类型则使用文件类型来填充，不匹配时会报签名异常
    // NOTE must before file
    if (!fields['Content-Type'] && data.contentTypeStartsWith) {
      if (!file.type.startsWith(data.contentTypeStartsWith)) {
        alert('文件类型错误!')
        return
      } else {
        FD.append('Content-Type', file.type)
      }
    }

    // NOTE must do last
    FD.append('file', file)

    // Define what happens on successful data submission
    XHR.addEventListener('load', function(event) {
      callback(fields['key']);
      alert('Yeah! Data sent and response loaded.');
    });

    // Define what happens in case of error
    XHR.addEventListener('error', function(event) {
      alert('Oops! Something went wrong.');
    });


    XHR.open('POST', url);

    XHR.onload = function (event) {
      // 用于结果回传
      // callback(event)
      if (XHR.status == 200) {
        // upload success! add some feeback to fileDom
      } else {
        // upload fail!
      }

      event.preventDefault()
    }

    XHR.upload.onprogress = function(e) {
      let percent = parseInt(e.loaded / e.total * 100, 10)
      // fileDom.text('上传进度: ' + percent + '%')
    }

    for (var x of FD.entries()) {
      console.log(x[0]+ ': ' + x[1]);
    }

    XHR.send(FD);
  }

  var bindUploadModal = function (rootDom) {
    var baseModal = `
  <div id="{{modalID}}" class="uploader-modal uploader-open">
    <div class="uploader-modal-window">
      <span class="uploader-close" data-dismiss="uploader-modal">&times;</span>

      <h3>{{title}}</h3>

      <div class="content">
        {{content}}
        <button class="cancel-upload">取消</button>
        <button class="upload-file" data-output={{output}}>上传</button>
      </div>
    </div>
  </div>
      `;

    var elements = rootDom.getElementsByClassName('s3_uploader');

    let inputFieldClicked = function (e) {
      let current = e.target;
      let data = current.dataset;
      var XHR = new XMLHttpRequest();
      var FD  = new FormData();
      FD.append('clazz', data.clazz)
      FD.append('field', data.field)
      XHR.open('GET', data.url)

      current.uid = current.uid || ('a' + Math.random().toString(36).substring(2));
      let class_mark = current.uid

      current.setAttribute('disabled', true)
      current.classList.add(class_mark)

      XHR.onload = function (){
        if (XHR.status == 200) {
          let currentModal = baseModal.replace(
              '{{title}}', '请选择需要上传的文件'
            ).replace(
              '{{content}}', XHR.response
            ).replace(
              '{{modalID}}', data.modalId
            ).replace(
              '{{output}}', 'input.'+ class_mark
            );
          current.insertAdjacentHTML('afterend', currentModal)
          bindUploadModalEvent(document.getElementById(data.modalId))
        }
        current.removeAttribute('disabled')
      }
      XHR.send(FD)
      e.preventDefault();
    }

    for (let idx = 0; idx < elements.length; idx++) {
      const element = elements[idx];
      if (element.inited_field_click) continue;
      element.addEventListener('click', inputFieldClicked)
      element.inited_field_click = true
    }
  }

  var closeUploadModal = function (e) {
    let target = e.target;

    getCurrentModal(target).remove()
    e.preventDefault();
  }

  var cancelUpload = function (e) {
    let target = e.target;
    if (window.confirm('放弃修改吗？当前文件将不会存储！！')) {
      // TODO 不要修改文件URL
    }
    getCurrentModal(target).remove()
    e.preventDefault();
  }

  var getCurrentModal = function (base) {
    return base.closest('[class="uploader-modal uploader-open"]')
  }

  var uploadToS3 = function (e) {
    let target = e.target

    let fileDom = getCurrentModal(target).querySelector('input[name="file"]')
    let data = fileDom.dataset;
    let files = fileDom.files

    for (let idx = 0; idx < files.length; idx++) {
      const f = files[idx];

      // 用于将数据返回到前一个页面
      try {
        send2S3(f, data, function (v) {
          let ds = target.dataset;
          if (!ds.output || !v) return;

          document.querySelector(ds.output).setAttribute('value', v)
        })
      } catch (error) {
        console.error(error)
        // set error
      }
    }
    e.preventDefault();
  }

  var bindUploadModalEvent = function (modal) {
    modal.querySelector('span[class="uploader-close"]').addEventListener('click', closeUploadModal)
    modal.querySelector('button[class="cancel-upload"]').addEventListener('click', cancelUpload)
    modal.querySelector('button[class="upload-file"]').addEventListener('click', uploadToS3)
  }

  $(document).ready(function () {
    bindUploadModal(this)
  })
