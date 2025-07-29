local orgs = import 'vendor/otterdog-defaults/otterdog-defaults.libsonnet';

local customRuleset(name, checks) =
  orgs.newRepoRuleset(name) {
    allows_creations: true,
    bypass_actors+: [
      "@eclipse-kura/iot-kura-project-leads",
      "@eclipse-kura/merge-bypass"
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
      status_checks+: checks,
    },
  };

// Creates a standardized repository configuration for Eclipse Kura addon projects.
// This function provides consistent settings for all Kura addon repositories including
// branch protection rules, merge policies, and GitHub Pages configuration.
//
// Parameters:
//   name: The repository name
//   description: A brief description of the addon's purpose
//   ruleset_disable: If true, disables all branch protection rulesets (default: false). Set this to "true" when creating a new repository.
//   docs_disable: If true, disables all branch protection rulesets for documentation branches and related environments (default: true)
//
local newKuraAddonRepo(name, description, ruleset_disable=false, docs_disable=true) =
  orgs.newRepo(name) {
    // Common settings
    default_branch: "develop",
    description: description,
    allow_update_branch: true,
    delete_branch_on_merge: true,
    has_wiki: false,
    has_discussions: false,
    web_commit_signoff_required: false,
    workflows+: {
      enabled: true,
    },
    // Squash merge only
    allow_merge_commit: false,
    allow_rebase_merge: false,
    allow_squash_merge: true,
    squash_merge_commit_title: "PR_TITLE",
    // Branch protection rules
    rulesets: if ruleset_disable then [] else [
      customRuleset('develop', [
        "call-workflow-in-public-repo / Validate PR title",
        "continuous-integration/jenkins/pr-merge",
      ]),
      customRuleset('release-*', [
        "call-workflow-in-public-repo / Validate PR title",
        "continuous-integration/jenkins/pr-merge",
      ]),
    ] + (
      if docs_disable then [] else [
        customRuleset('docs-develop', [
          "call-workflow-in-public-repo / Validate PR title",
        ]),
        customRuleset('docs-release-*', [
          "call-workflow-in-public-repo / Validate PR title",
        ]),
      ]
    ),
    // Documentation
    gh_pages_build_type: if docs_disable then 'disabled' else 'legacy',
    gh_pages_source_path: if docs_disable then null else '/',
    gh_pages_source_branch: if docs_disable then null else 'gh-pages',
    environments: if docs_disable then [] else [
      orgs.newEnvironment('github-pages') {
        branch_policies+: [
          "gh-pages",
        ],
        deployment_branch_policy: "selected",
      },
    ],
  };

orgs.newOrg('iot.kura', 'eclipse-kura') {
  settings+: {
    description: "",
    name: "Eclipse Kura",
    web_commit_signoff_required: false,
  },
  teams+: [
    orgs.newTeam('merge-bypass') {
      members+: [
        "eclipse-kura-bot",
      ],
    },
  ],
  secrets+: [
    orgs.newOrgSecret('BOT_GITHUB_TOKEN') {
      value: "pass:bots/iot.kura/github.com/api-token",
    },
    orgs.newOrgSecret('KURA_BOT_GITHUB_TOKEN') {
      value: "pass:bots/iot.kura/github.com/api-token-5404",
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
    // ****************************************
    // * Kura-core
    // ****************************************
    orgs.newRepo('kura') {
      allow_rebase_merge: false,
      code_scanning_default_setup_enabled: false,
      default_branch: "develop",
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
      rulesets: [
        customRuleset('develop', [
          "call-workflow-in-public-repo / Validate PR title",
          "continuous-integration/jenkins/pr-merge",
        ]),
        customRuleset('release-*', [
          "Validate PR title",
          "continuous-integration/jenkins/pr-merge",
        ]),
        customRuleset('docs-develop', [
          "Validate PR title",
        ]),
        customRuleset('docs-release-*', [
          "Validate PR title",
        ]),
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
    // ****************************************
    // * Kura addons
    // ****************************************
    newKuraAddonRepo('kura-apps', 'Applications for Eclipse Kura™ framework'),
    newKuraAddonRepo('kura-artemis', 'Eclipse Kura™ Artemis MQTT server addon', docs_disable=false),
    newKuraAddonRepo('kura-command', 'Eclipse Kura™ Command addon'),
    newKuraAddonRepo('kura-management-ui', 'Eclipse Kura™ Web UI'),
    newKuraAddonRepo('kura-metapackage', 'Eclipse Kura™ Metapackage'),
    newKuraAddonRepo('kura-networking', 'Eclipse Kura™ Networking addon'),
    newKuraAddonRepo('kura-position', 'Eclipse Kura™ Position addon'),
    newKuraAddonRepo('kura-wires', 'Eclipse Kura™ Wires and Assets'),
    newKuraAddonRepo('kura-bluetooth', 'Eclipse Kura™ Bluetooth'),
    // ****************************************
    // * CI repos
    // ****************************************
    orgs.newRepo('.github') {
      allow_merge_commit: false,
      allow_rebase_merge: false,
      allow_squash_merge: true,
      description: "Eclipse Kura™ automation repository",
      delete_branch_on_merge: true,
      squash_merge_commit_title: "PR_TITLE",
      has_wiki: false,
      rulesets: [
        customRuleset('main', [
          "call-workflow-in-public-repo / Validate PR title"
        ]),
      ]
    },
    orgs.newRepo('add-ons-shared-libraries') {
      allow_merge_commit: false,
      allow_rebase_merge: false,
      allow_squash_merge: true,
      allow_update_branch: true,
      default_branch: "develop",
      description: "Eclipse Kura™ projects' Jenkins shared libraries",
      delete_branch_on_merge: true,
      has_wiki: false,
      web_commit_signoff_required: false,
      squash_merge_commit_title: "PR_TITLE",
      rulesets: [
        customRuleset('develop', [
          "call-workflow-in-public-repo / Validate PR title"
        ]),
        customRuleset('plugin/*', [
          "call-workflow-in-public-repo / Validate PR title"
        ])
      ]
    },
    // ****************************************
    // * Website and tools
    // ****************************************
    orgs.newRepo('kura-website') {
      allow_merge_commit: true,
      allow_update_branch: false,
      default_branch: "master",
      homepage: "https://eclipse.dev/kura/",
      description: "Eclipse Kura™ website",
      delete_branch_on_merge: false,
      web_commit_signoff_required: false,
      rulesets: [
        customRuleset('hugo_migration', [
          "Validate PR title",
        ]),
      ],
      workflows+: {
        enabled: true,
      },
    },
    orgs.newRepo('metadata-generator') {
      allow_merge_commit: false,
      allow_rebase_merge: false,
      allow_squash_merge: true,
      default_branch: "develop",
      description: "Eclipse Kura™ Metadata Generator",
      delete_branch_on_merge: true,
      has_wiki: false,
      has_projects: false,
      web_commit_signoff_required: false,
      squash_merge_commit_title: "PR_TITLE",
      rulesets: [
        customRuleset('develop', [
          "call-workflow-in-public-repo / Validate PR title",
        ]),
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
      rulesets: [
        customRuleset('develop', [
          "call-workflow-in-public-repo / Validate PR title",
        ]),
      ],
      workflows+: {
        enabled: true,
      },
    }
  ],
}
