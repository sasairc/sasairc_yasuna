sasairc_yasuna
===

<https://twitter.com/sasairc_yasuna> の中身。	

[844196_renge](https://github.com/844196/844196_renge)を参考にさせて頂きました。

## Requirements

```perl
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

## Functions

|Command|Pattern|Description|
|:-----:|-------|-----------|
|number `INT`|(number&#x7C;n) [0-9]+$|指定した番号`INT`の台詞を出力|
|version|version$|yasunaのバージョンを出力|
|oudon|(お?うどん&#x7C;o?udon)$|[@keep_off07](https://twitter.com/keep_off07)さんにおうどん :ramen: をあげる|
|uptime|uptime$|稼働システムのuptimeを通知する|
|talk|(none)|しゃべる|
