import EventKit
import FlutterMacOS

/// EventKit（リマインダー）と Flutter を繋ぐ platform channel プラグイン。
/// iOS 版も同じインターフェースで実装できる（EventKit は macOS/iOS 共通）。
class RemindersPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.futo4.tsukaikiri/reminders",
      binaryMessenger: registrar.messenger
    )
    let instance = RemindersPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private let store = EKEventStore()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestAccess":
      requestAccess(result: result)
    case "getLists":
      getLists(result: result)
    case "createList":
      guard let args = call.arguments as? [String: Any],
            let name = args["name"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "name required", details: nil))
        return
      }
      createList(name: name, result: result)
    case "addItems":
      guard let args = call.arguments as? [String: Any],
            let listId = args["listId"] as? String,
            let items = args["items"] as? [[String: Any]]
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "listId and items required", details: nil))
        return
      }
      addItems(listId: listId, items: items, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - requestAccess

  private func requestAccess(result: @escaping FlutterResult) {
    if #available(macOS 14.0, *) {
      store.requestFullAccessToReminders { granted, error in
        DispatchQueue.main.async {
          if let error = error {
            result(FlutterError(code: "ACCESS_ERROR", message: error.localizedDescription, details: nil))
          } else {
            result(granted)
          }
        }
      }
    } else {
      store.requestAccess(to: .reminder) { granted, error in
        DispatchQueue.main.async {
          if let error = error {
            result(FlutterError(code: "ACCESS_ERROR", message: error.localizedDescription, details: nil))
          } else {
            result(granted)
          }
        }
      }
    }
  }

  // MARK: - getLists

  private func getLists(result: @escaping FlutterResult) {
    let calendars = store.calendars(for: .reminder)
    let lists: [[String: String]] = calendars.map { cal in
      ["id": cal.calendarIdentifier, "name": cal.title]
    }
    result(lists)
  }

  // MARK: - createList

  private func createList(name: String, result: @escaping FlutterResult) {
    let calendar = EKCalendar(for: .reminder, eventStore: store)
    calendar.title = name
    // iCloud ソース優先、なければローカルを使う
    let source =
      store.sources.first { $0.sourceType == .calDAV && $0.title.lowercased() == "icloud" }
      ?? store.sources.first { $0.sourceType == .local }
    guard let source = source else {
      result(FlutterError(code: "NO_SOURCE", message: "No suitable calendar source found", details: nil))
      return
    }
    calendar.source = source
    do {
      try store.saveCalendar(calendar, commit: true)
      result(["id": calendar.calendarIdentifier, "name": calendar.title])
    } catch {
      result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
    }
  }

  // MARK: - addItems

  private func addItems(listId: String, items: [[String: Any]], result: @escaping FlutterResult) {
    guard let calendar = store.calendar(withIdentifier: listId) else {
      result(FlutterError(code: "LIST_NOT_FOUND", message: "List \(listId) not found", details: nil))
      return
    }
    let predicate = store.predicateForReminders(in: [calendar])
    store.fetchReminders(matching: predicate) { existing in
      let existingTitles = Set(
        (existing ?? [])
          .filter { !$0.isCompleted }
          .compactMap { $0.title?.lowercased() }
      )
      var savedCount = 0
      for item in items {
        guard let title = item["title"] as? String else { continue }
        if existingTitles.contains(title.lowercased()) { continue }
        let reminder = EKReminder(eventStore: self.store)
        reminder.title = title
        if let notes = item["notes"] as? String { reminder.notes = notes }
        reminder.calendar = calendar
        try? self.store.save(reminder, commit: false)
        savedCount += 1
      }
      do {
        try self.store.commit()
        DispatchQueue.main.async { result(savedCount) }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "COMMIT_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }
}
