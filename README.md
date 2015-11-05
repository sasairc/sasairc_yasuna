sasairc_yasuna
===

<https://twitter.com/sasairc_yasuna> の中身。	

[844196_renge](https://github.com/844196/844196_renge)を参考にさせて頂きました。

## Requirements
`yasuna`と`n_cipher`に加えて、`perl5`で用いる下記ライブラリが必要です。
```perl5
FindBin
YAML::Tiny
Net::OAuth
AnyEvent::Twitter::Stream 
Net::Twitter::Lite::WithAPIv1_1
```

## Usage
```shellsession
% cat <<EOF > config.yml
TWITTER_CONSUMER_KEY:           ''
TWITTER_CONSUMER_SECRET:        ''
TWITTER_ACCESS_TOKEN:           ''
TWITTER_ACCESS_TOKEN_SECRET:    ''
EOF
% nohup ./reply.pl &!
```
`periodic.pl`はcrontabへ登録して下さい。

## Functions
[N暗号](https://github.com/844196/n_cipher)のシード及びデリミタの値は`--seed="くそぅ" --delimiter="！"`です。

|Command|Pattern|Description|
|:-----:|-------|-----------|
|encode `STR`|encode\s(.+)|N暗号のエンコード|
|decode `STR`|decode\s(.+)|N暗号のデコード|
|number `INT`|(number&#x7C;n)\s[0-9]+$|指定した番号`INT`の台詞を出力|
|version|version$|yasunaのバージョンを出力|
|oudon|(お?うどん&#x7C;o?udon)$|[@keep_off07](https://twitter.com/keep_off07)さんにおうどん :ramen: をあげる|
|uptime|uptime$|稼働システムのuptimeを通知する|
|talk|(none)|しゃべる|
