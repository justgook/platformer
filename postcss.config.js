module.exports = ctx => ({
    map: false,
    parser: ctx.options.parser,
    plugins: {
        'postcss-extract-media-query': {
            minimize: true,
            combine: true,
            queries: {
                'screen and (min-width: 1024px)': 'desktop'
            },
            output: {
                path: ctx.file.dirname,
                name: '[name]-[query].[ext]'
            }
        }
    }
});
