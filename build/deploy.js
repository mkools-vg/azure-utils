const fs = require('fs')
const path = require('path')
const ncp = require('ncp').ncp
const mkdirp = require('mkdirp')
const rimraf = require('rimraf')

const version = JSON.parse(fs.readFileSync('package.json', 'utf-8')).version

const powerShellDir = path.join(process.env['USERPROFILE'], 'My Documents', 'WindowsPowerShell')
const moduleDir = path.join(powerShellDir, 'Modules', 'azure-utils')

if (fs.existsSync(moduleDir)) {
    rimraf.sync(moduleDir)
}

const destinationDir = path.join(moduleDir, `${version}`)
mkdirp.sync(destinationDir)

ncp('src', destinationDir, function (err) {
    if (err) {
        throw err
    }

    const profilePath = path.join(powerShellDir, "profile.ps1")
    let content = fs.readFileSync(profilePath, "utf-8")
    const regex = /^Import-Module azure-utils$/m

    if (!regex.test(content)) {
        fs.appendFileSync(profilePath, 'Import-Module azure-utils\n')
    }
})
