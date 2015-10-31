sasairc_yasuna
===

<https://twitter.com/sasairc_yasuna> の中身。	
リプライ（特定の文字）に反応するだけ。

## Requirements

```ruby
Perl5
FindBin
YAML::Tiny
Net::OAuth
AnyEvent::Twitter::Stream 
Net::Twitter::Lite::WithAPIv1_1
```

## Functions

|Command|Pattern|Description|
|:-----:|-------|-----------|
|number `INT`|number [0-9]+$|指定した番号`INT`の台詞を出力|
|version|version$|yasunaのバージョンを出力|
|oudon|(お?うどん&#x7C;o?udon)$|[@keep_off07](https://twitter.com/keep_off07)さんにおうどん :ramen: をあげる|
|talk|(none)|しゃべる|
