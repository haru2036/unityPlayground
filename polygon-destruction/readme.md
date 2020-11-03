# polygon-destruction(random)
ポリゴンをランダムに浮遊させるシェーダ

## パラメータについて
|name|description|
|---|---|
|WeightMap|動きと不透明度を指定するテクスチャです。0に近づくと透明に近づき、動く範囲も狭くなります。|
|Color|Emission Colorを使うように変更しているところです。今後使われなくなる予定なので、色はEmission Colorに指定してください。|
|Emission Color|ベースカラーの指定です。HDRカラーを使用すると発光するようになります。|
|Scale Factor|分解したポリゴンの移動距離の倍率です。負の値を指定すると内側に移動するようになります。|
|Line Width|ワイヤフレームの太さを指定します。|
|Speed|アニメーションの速度を指定します。|