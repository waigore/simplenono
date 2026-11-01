extends SceneTree
## Integration harness entry (`specs/technical/verification.md` H1-H4; #166).
##
##     godot --headless --path game -s test/integration/run_protocol.gd -- \
##         --protocol=paint --run-dir=docs/quality/evidence/issue-166/<run-id>
##
## Runs one named protocol from [`IntegrationProtocols`](protocol_catalog.gd), tears
## the scene down, and exits `0` on pass, `1` on a protocol failure, or `2` on usage
## or when a game protocol is asked for without the one debug seam flag
## (`verification.md` H2). A gate failure writes no run folder.
##
## `self-test` is CI-only: it refuses a run folder under `docs/quality/`, so it can
## never be cited as quality evidence.

const EXIT_OK := 0
const EXIT_PROTOCOL_FAILED := 1
const EXIT_USAGE := 2

const QUALITY_ROOT := "docs/quality"


func _initialize() -> void:
	var args := IntegrationArgs.parse()
	var protocol_id := IntegrationArgs.text(args, IntegrationArgs.PROTOCOL)
	var run_dir := IntegrationArgs.text(args, IntegrationArgs.RUN_DIR)
	if protocol_id.is_empty() or run_dir.is_empty():
		printerr("integration: --protocol and --run-dir are required.")
		quit(EXIT_USAGE)
		return
	if not IntegrationProtocols.has(protocol_id):
		printerr("integration: unknown protocol %s." % protocol_id)
		quit(EXIT_USAGE)
		return
	var spec := IntegrationProtocols.spec(protocol_id)
	if bool(spec.get("seams", true)) and not DebugSeams.is_enabled():
		printerr(
			(
				"integration: the debug seams are off; game protocols run only against "
				+ "the debug build with --debug-seams (verification.md H2)."
			)
		)
		quit(EXIT_USAGE)
		return
	if bool(spec.get("ci_only", false)) and run_dir.contains(QUALITY_ROOT):
		printerr("integration: self-test is CI-only and cannot write a quality evidence run.")
		quit(EXIT_USAGE)
		return
	var folder := IntegrationRunFolder.new(run_dir)
	if not folder.ensure():
		printerr("integration: cannot create the run folder at %s." % run_dir)
		quit(EXIT_USAGE)
		return
	var session_id := IntegrationArgs.text(args, IntegrationArgs.SESSION_ID, _default_session_id())
	var build_id := IntegrationArgs.text(
		args, IntegrationArgs.BUILD_ID, Engine.get_version_info().get("string", "godot")
	)
	var supervisor := IntegrationSupervisor.new()
	supervisor.configure(spec, folder, session_id, build_id)
	supervisor.finished.connect(_on_finished)
	root.add_child(supervisor)


func _on_finished(result: Dictionary) -> void:
	var outcome := String(result.get("outcome", "fail"))
	print(
		(
			"HARNESS protocol=%s outcome=%s run=%s"
			% [result.get("protocol", ""), outcome, result.get("log", "")]
		)
	)
	quit(EXIT_OK if outcome == "pass" else EXIT_PROTOCOL_FAILED)


func _default_session_id() -> String:
	return "harness-%d" % int(Time.get_unix_time_from_system())
