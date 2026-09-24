-- Java language server (jdtls), merged into kickstart's `servers` table (SECTION 6).
--
-- * Finds every installed JDK in `~/.sdkman/candidates/java/*` and
--   `/Library/Java/JavaVirtualMachines/*`, so installing another JDK is enough - no edit here.
--   The newest one is the default for single files and projects without a declared
--   toolchain; the newest LTS (17/21/25) runs jdtls itself and the Gradle importer, because
--   Gradle cannot parse class files from a JDK newer than it knows.
-- * Runs jdtls with the Lombok agent Mason ships, so `@Slf4j`, `@Getter`, `@Builder`, ...
--   resolve.
-- * Formats with the Eclipse profile in `java-formatter.xml` (an approximation of IntelliJ's
--   defaults, see README) and uses IntelliJ's import order and star-import thresholds.
--
-- Works for Gradle and Maven projects; the root is detected from `gradlew`, `settings.gradle`,
-- `pom.xml` or `.git`. For debugging and a test runner swap this for
-- https://github.com/mfussenegger/nvim-jdtls.

---@type { name: string, path: string, default: boolean? }[]
local java_runtimes = {}
local gradle_java_home = nil
do
  local seen, found = {}, {}
  local roots = {
    vim.fs.joinpath(vim.env.HOME, '.sdkman/candidates/java'),
    '/Library/Java/JavaVirtualMachines',
  }
  for _, root in ipairs(roots) do
    for name, type_ in vim.fs.dir(root) do
      if (type_ == 'directory' or type_ == 'link') and name ~= 'current' then
        -- A JDK home is either `<dir>` (SDKMAN) or `<dir>/Contents/Home` (macOS bundles).
        local home = vim.fs.joinpath(root, name)
        if not vim.uv.fs_stat(vim.fs.joinpath(home, 'bin/javac')) then home = vim.fs.joinpath(home, 'Contents/Home') end
        local release = vim.fs.joinpath(home, 'release')
        if vim.uv.fs_stat(vim.fs.joinpath(home, 'bin/javac')) and vim.uv.fs_stat(release) then
          -- `release` is a properties file; JAVA_VERSION="21.0.12" -> feature version 21.
          local version = table.concat(vim.fn.readfile(release), '\n'):match 'JAVA_VERSION="(%d+)'
          if version and not seen[version] then
            seen[version] = true
            found[#found + 1] = { name = 'JavaSE-' .. version, path = home, version = tonumber(version) }
          end
        end
      end
    end
  end
  table.sort(found, function(a, b) return a.version > b.version end)
  for i, jdk in ipairs(found) do
    -- Newest JDK compiles single files and projects with no declared toolchain.
    java_runtimes[i] = { name = jdk.name, path = jdk.path, default = i == 1 or nil }
    -- Gradle runs on the newest LTS, which it is far likelier to support than a
    -- bleeding-edge release; fall back to the newest JDK if no LTS is installed.
    if not gradle_java_home and (jdk.version == 25 or jdk.version == 21 or jdk.version == 17) then gradle_java_home = jdk.path end
  end
  gradle_java_home = gradle_java_home or (found[1] and found[1].path)
end

---@type table<string, vim.lsp.Config>
return {
  jdtls = {
    -- The Mason launcher runs jdtls on `$JAVA_HOME` (or `java` on `$PATH`) and needs 21+.
    -- Point it at the newest LTS found above so the system Java 8 is never used.
    cmd_env = { JAVA_HOME = gradle_java_home },
    -- Lombok-generated members only resolve when jdtls itself runs with the Lombok agent.
    cmd = {
      vim.fn.stdpath 'data' .. '/mason/bin/jdtls',
      '--jvm-arg=-javaagent:' .. vim.fn.stdpath 'data' .. '/mason/packages/jdtls/lombok.jar',
    },
    settings = {
      java = {
        inlayHints = {
          parameterNames = {
            enabled = 'all',
            exclusions = { '*.of', '*.valueOf' },
          },
        },
        -- Format like IntelliJ IDEA's default Java code style (what the team uses).
        -- The Eclipse profile lives in the config root; see its comments for the mapping.
        format = {
          enabled = true,
          settings = {
            url = vim.fn.stdpath 'config' .. '/java-formatter.xml',
            profile = 'IntelliJ Default',
          },
          comments = { enabled = false }, -- IntelliJ does not reflow comments
        },
        -- IntelliJ default import layout: other imports, javax, java, then static imports,
        -- collapsing to `pkg.*` after 5 classes (3 for static) from one package.
        completion = { importOrder = { '', 'javax', 'java', '#' } },
        sources = { organizeImports = { starThreshold = 5, staticStarThreshold = 3 } },
        configuration = {
          -- JDKs jdtls may compile against. A project picks one via its build file
          -- (Gradle `toolchain`/`sourceCompatibility`, Maven `maven.compiler.release`);
          -- `default = true` is used for single files and projects that say nothing.
          -- Names must be Eclipse execution environments: JavaSE-21, JavaSE-26, ...
          runtimes = java_runtimes,
        },
        import = {
          gradle = {
            -- Pin the importer to the newest LTS found above, independent of the JDK
            -- nvim/jdtls run on (a too-new JDK fails project import with
            -- "Unsupported class file major version").
            java = { home = gradle_java_home },
          },
        },
      },
    },
  },
}
