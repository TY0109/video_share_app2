const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
// @import './videos/**'; といった読み込みを可能にする設定を追加(自分で追加したもの)
environment.loaders.get('sass').use.push('import-glob-loader')
// jqueryをどこからでも参照できる設定
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery'
    })
)

module.exports = environment
