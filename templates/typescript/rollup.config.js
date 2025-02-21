import typescript from "@rollup/plugin-typescript";
import pkg from "./package.json" with { type: "json" };
import nodeResolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";

export default [
    {
        input: pkg.main,
        output: {
            name: pkg.name,
            file: `dist/index.js`,
            format: "es"
        },
        plugins: [
            typescript(),
            nodeResolve(),
            commonjs()
        ]
    }
]