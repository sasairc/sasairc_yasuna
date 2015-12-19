sasairc_yasuna
===

![](http://40.media.tumblr.com/88c00f60185c93d419fe1484c08a88d8/tumblr_nxehzzPUgA1u2jamko1_1280.png)

<https://twitter.com/sasairc_yasuna> の中身。	

[844196_renge](https://github.com/844196/844196_renge)を参考にさせて頂きました。

## Requirements

`yasuna`と`n_cipher`に加えて、`perl5`で用いる下記ライブラリが必要です。

```perl5
FindBin
YAML::Tiny
Net::OAuth
AnyEvent::Twitter
AnyEvent::Twitter::Stream 
```

## Usage

```shellsession
% cat <<EOF > config.yml
TWITTER_BOT_SCREEN_NAME:        '@sasairc_yasuna'
TWITTER_CONSUMER_KEY:           ''
TWITTER_CONSUMER_SECRET:        ''
TWITTER_ACCESS_TOKEN:           ''
TWITTER_ACCESS_TOKEN_SECRET:    ''
EOF
% nohup ./reply.pl &!
```

`periodic.pl`はcrontabへ登録して下さい。

## Permission

一部機能に関しては、`user.yml`の`allow:`に含まれるユーザのみ使用することができます。

## Functions

[N暗号](https://github.com/844196/n_cipher)のシード及びデリミタの値は`--seed="くそぅ" --delimiter="！"`です。

|Command|Pattern|Description|
|:-----:|-------|-----------|
|encode `STR`|encode\s(.+)|N暗号のエンコード|
|decode `STR`|decode\s(.+)|N暗号のデコード [※1](#note1)|
|number `INT`|(number&#x7C;n)\s[0-9]+$|指定した番号`INT`の台詞を出力|
|version|version$|yasunaのバージョンを出力|
|oudon|^(お?うどん&#x7C;o?udon)$|[@keep_off07](https://twitter.com/keep_off07)さんにおうどん :ramen: をあげる [※2](#note2)|
|osakana|^(お?さかな&#x7C;o?sakana)$|[@sasairc_2](https://twitter.com/sasairc_2)におさかな :fish: をあげる|
|uptime|uptime$|稼働システムのuptimeを通知する|
|revision|revision$|稼働中スクリプトのリビジョンを通知する|
|talk|talk(?:.\*)\z|しゃべる|

<a name ="note1">※1 許可されたユーザのみ、デコード結果でリプライすることが可能。  
<a name ="note2">※2 許可されたユーザのみ、おうどんをあげることができる。
