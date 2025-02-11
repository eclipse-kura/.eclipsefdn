local orgs = import 'vendor/otterdog-defaults/otterdog-defaults.libsonnet';

local customDevRuleset(name) =
  orgs.newRepoRuleset(name) {
    allows_creations: true,
    bypass_actors+: [
      "@eclipse-kura/iot-kura-project-leads"
    ],
    include_refs+: [
      std.format("refs/heads/%s", name),
    ],
    required_pull_request+: {
        dismisses_stale_reviews: true,
        requires_last_push_approval: true,
        required_approving_review_count: 1,
    },
    required_status_checks+: {
      status_checks+: [
        "Validate PR title",
        "continuous-integration/jenkins/pr-merge",
      ],
    },
  };

local customDocRuleset(name) =
  orgs.newRepoRuleset(name) {
    allows_creations: true,
    bypass_actors+: [
      "@eclipse-kura/iot-kura-project-leads"
    ],
    include_refs+: [
      std.format("refs/heads/%s", name),
    ],
    required_pull_request+: {
        dismisses_stale_reviews: true,
        requires_last_push_approval: true,
        required_approving_review_count: 1,
    },
    required_status_checks+: {
      status_checks+: [
        "Validate PR title",
      ],
    },
  };

orgs.newOrg('iot.kura', 'eclipse-kura') {
  settings+: {
    description: "",
    name: "Eclipse Kura",
    web_commit_signoff_required: false,
  },
  secrets+: [
    orgs.newOrgSecret('BOT_GITHUB_TOKEN') {
      value: "pass:bots/iot.kura/github.com/api-token",
    },
  ],
  webhooks+: [
    orgs.newOrgWebhook('https://ci.eclipse.org/kura/github-webhook/') {
      content_type: "json",
      events+: [
        "pull_request",
        "push"
      ],
    },
  ],
  _repositories+:: [
    orgs.newRepo('kura') {
      allow_rebase_merge: false,
      code_scanning_default_setup_enabled: false,
      default_branch: "develop",
      dependabot_security_updates_enabled: true,
      description: "Eclipse Kura™ is a versatile framework to supercharge your edge devices, streamlining the process of configuring your gateway, connecting sensors, and IoT devices to seamlessly collect, process, and send data to the cloud.",
      gh_pages_build_type: "legacy",
      gh_pages_source_branch: "gh-pages",
      gh_pages_source_path: "/",
      has_discussions: true,
      homepage: "https://eclipse.dev/kura/",
      squash_merge_commit_title: "PR_TITLE",
      topics+: [
        "eclipseiot",
        "gateway",
        "internet-of-things",
        "iot",
        "java"
      ],
      web_commit_signoff_required: false,
      webhooks: [
        orgs.newRepoWebhook('https://hooks.dependencyci.com/events') {
          content_type: "json",
          events+: [
            "pull_request",
            "push"
          ],
          secret: "********",
        },
        orgs.newRepoWebhook('https://app.fossa.io/hooks/github/git%2Bhttps%3A%2F%2Fgithub.com%2Feclipse%2Fkura') {
          content_type: "json",
          events+: [
            "pull_request",
            "push"
          ],
          secret: "********",
        },
        orgs.newRepoWebhook('https://notify.travis-ci.org') {
          events+: [
            "create",
            "delete",
            "issue_comment",
            "member",
            "public",
            "pull_request",
            "push",
            "repository"
          ],
        },
        orgs.newRepoWebhook('https://webhooks.gitter.im/e/65c284ac4a47d5410a93') {
          events+: [
            "issue_comment",
            "issues",
            "pull_request",
            "push"
          ],
          secret: "********",
        },
        orgs.newRepoWebhook('https://ci.eclipse.org/kura/github-webhook/') {
          content_type: "json",
          events+: [
            "create",
            "delete",
            "pull_request",
            "push"
          ],
          secret: "********",
        },
      ],
      rulesets: [
        customDevRuleset('develop'),
        customDevRuleset('release-*'),
        customDocRuleset('docs-develop'),
        customDocRuleset('docs-release-*')
      ],
      environments: [
        orgs.newEnvironment('github-pages') {
          branch_policies+: [
            "gh-pages",
            "gh-pages-backup"
          ],
          deployment_branch_policy: "selected",
        },
      ],
    },
    orgs.newRepo('kura-apps') {
      allow_merge_commit: true,
      allow_update_branch: false,
      default_branch: "master",
      delete_branch_on_merge: false,
      has_wiki: false,
      web_commit_signoff_required: false,
    },
    orgs.newRepo('kura-website') {
      allow_merge_commit: true,
      allow_update_branch: false,
      default_branch: "master",
      homepage: "https://eclipse.dev/kura/",
      description: "Eclipse Kura™ website",
      delete_branch_on_merge: false,
      web_commit_signoff_required: false,
      rulesets: [
        customDocRuleset('hugo_migration'),
      ],
      workflows+: {
        enabled: true,
      },
    },
    orgs.newRepo('copyright-check') {
      allow_merge_commit: false,
      allow_rebase_merge: false,
      allow_squash_merge: true,
      default_branch: "develop",
      description: "Copyright check tool for Eclipse Kura™ projects",
      delete_branch_on_merge: true,
      web_commit_signoff_required: false,
      workflows+: {
        enabled: true,
      },
    },
  ],
} + {
  # snippet added due to 'https://github.com/EclipseFdn/otterdog-configs/blob/main/blueprints/add-dot-github-repo.yml'
  _repositories+:: [
    orgs.newRepo('.github')
  ],
}
