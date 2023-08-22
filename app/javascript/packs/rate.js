$('.star5-average-rating').each(function (index, e) {
  // レビューの値を取得
  let starRate = $(this).data('rate');

  // 0.5で割り切れない場合
  if(starRate % 0.5 !== 0) {
    // widthの値
    let widthRate = Math.round(((starRate / 5) * 100), 2);

    // 追加する疑似要素（星のレビュー値のdata-rate値，widthを設定する）
    let css = '.star5-average-rating[data-rate="' + starRate + '"]:after { width:' + widthRate + '%; }';

    // style要素を作成してCSSを設定
    let style = $('<style>')
    style.text(css);

    // style要素を全体に追加
    $('body').append(style);
  }
});
