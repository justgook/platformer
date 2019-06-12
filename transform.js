/**
 * npm i -g jscodeshift
 * jscodeshift -t transform.js elm.js
 */
const glslx = require('glslx').compile;

module.exports = function (file, api, options) {
    const j = api.jscodeshift;
    const airity = new Map(); // Map(functionName, airity)
    const tree = j(file.source);

    // Build the initial airity map
    tree.find(j.VariableDeclarator).forEach(path => {
        if (
            path.node.id.type === "Identifier" &&
            path.node.init &&
            path.node.init.type === "CallExpression" &&
            path.node.init.callee.type === "Identifier" &&
            path.node.init.callee.name.match(/^F\d$/)
        ) {
            airity.set(
                path.node.id.name,
                Number(path.node.init.callee.name.substr(1))
            );
        }
    });

    // Add re-declarations of the existing functions
    tree.find(j.VariableDeclarator).forEach(path => {
        if (
            path.node.id.type === "Identifier" &&
            path.node.init &&
            path.node.init.type === "Identifier" &&
            airity.has(path.node.init.name)
        ) {
            airity.set(path.node.id.name, airity.get(path.node.init.name));
        }
    });

    // Transform the A1..n calls
    return tree
        .find(j.CallExpression)
        .forEach(path => {
            if (
                path.node.callee.type === "Identifier" &&
                path.node.callee.name.match(/^A\d$/) &&
                path.node.arguments.length > 1 &&
                path.node.arguments[0].type === "Identifier" &&
                airity.get(path.node.arguments[0].name) ===
                path.node.arguments.length - 1 &&
                airity.get(path.node.arguments[0].name) ===
                Number(path.node.callee.name.substr(1))
            ) {
                path.node.callee = {
                    type: "MemberExpression",
                    object: {
                        type: "Identifier",
                        name: path.node.arguments[0].name
                    },
                    property: {
                        type: "Identifier",
                        name: "f"
                    }
                };
                path.node.arguments.shift();
            }
        })
        .find(j.Literal)
        .filter((path) => path.value && path.value.value && path.value.value.length > 100)
        .replaceWith(nodePath => {
            const { node } = nodePath;

            const newValue = glslx(node.value, { renaming: 'none', format: "json", });
            if (newValue.log === "") {
                node.value = JSON.parse(newValue.output).shaders[0].contents;
            }

            return node;
        })
        .toSource();
};
