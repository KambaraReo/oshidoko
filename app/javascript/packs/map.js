let map;
let marker;
let geocoder;
let aft = false; // マーカーを管理するフラグ

// 初期マップの設定
window.initMap = function() {
  geocoder = new google.maps.Geocoder();

  map = new google.maps.Map(document.getElementById('map'), {
    center: { lat: 35.65263243481742, lng: 139.73823818822285 }, // 港区日向坂
    zoom: 15,
  });

  // 住所と緯度経度のデータが入っている場合，マーカーを設置する
  const savedAddress = document.getElementById('add').value;
  const savedLat = parseFloat(document.getElementById('lat').value);
  const savedLng = parseFloat(document.getElementById('lng').value);

  if (savedAddress && !isNaN(savedLat) && !isNaN(savedLng)) {
    const savedLocation = new google.maps.LatLng(savedLat, savedLng);
    createMarker(savedLocation, savedAddress);
  }
};

// 検索後のマップ作成
window.codeAddress = function() {
  const inputAddress = document.getElementById('address').value;
  geocoder.geocode({ address: inputAddress }, function(results, status) {
    if (status == 'OK') {
      const location = results[0].geometry.location;
      createMarker(location, results[0].formatted_address);
    } else {
      alert('該当する結果がありませんでした：' + status);
    }
  });
};

// マーカーを作成する関数
function createMarker(location, address) {
  if (aft) {
    marker.setMap(null);
  }

  map.setCenter(location);
  marker = new google.maps.Marker({
    map: map,
    position: location,
    icon: {
      url: '/assets/marker.svg',
      scaledSize: new google.maps.Size(50, 50),
    },
    draggable: true, // ドラッグを可能にする
  });

  aft = true; // 二度目以降か判断

  document.getElementById('add').value = address;
  document.getElementById('lat').value = location.lat();
  document.getElementById('lng').value = location.lng();

  // マーカーのドロップ（ドラッグ終了）時のイベント
  google.maps.event.addListener(marker, 'dragend', function(ev) {
    // 住所を取得
    geocoder.geocode({ location: ev.latLng }, function(results, status) {
      if (status === 'OK') {
        if (results[0]) {
          if (results[0].types.includes('plus_code')) {
            document.getElementById('add').value = '住所が存在しません';
          } else {
            document.getElementById('add').value = results[0].formatted_address;
          }
        } else {
          alert('住所が見つかりませんでした。');
        }
      } else {
        alert('該当する結果がありませんでした：' + status);
      }
    });
    // 緯度経度を取得
    document.getElementById('lat').value = ev.latLng.lat();
    document.getElementById('lng').value = ev.latLng.lng();
  });
}
