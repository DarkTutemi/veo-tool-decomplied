import QtQml

QtObject {
    id: root

    property var controller: null
    property string hostPath: ""
    property var localIdeas: []
    property var localTemplates: []
    property var ideas: root.controller ? root.controller.plannerIdeas : root.localIdeas
    property var templates: root.controller ? root.controller.plannerTemplates : root.localTemplates
    property string templateId: root.controller ? root.controller.plannerTemplateId : ""
    property var selectedTemplate: root.controller ? root.controller.plannerTemplate : ({})
    property var selectedIdea: ({})

    signal changed()
    signal applied(string topic)

    function refresh(templateId) {
        if (root.controller && root.controller.refreshPlanner) {
            root.controller.refreshPlanner(String(templateId || root.templateId || ""))
            changed()
        }
    }

    function generateIdeas(templateId, seedTopic, count) {
        // Ưu tiên bản async (AI call 5–30s — bản sync đứng hình GUI)
        if (root.controller && root.controller.generatePlannerIdeasAsync) {
            root.controller.generatePlannerIdeasAsync(String(templateId || root.templateId || ""), String(seedTopic || ""), count || 5)
            return { ok: true, async: true }
        }
        if (root.controller && root.controller.generatePlannerIdeas) {
            var result = root.controller.generatePlannerIdeas(String(templateId || root.templateId || ""), String(seedTopic || ""), count || 5)
            changed()
            return result || ({})
        }
        return { ok: false, error: "planner_generate_unavailable", message: "Planner generation unavailable" }
    }

    function addIdea(topic, templateId) {
        if (root.controller && root.controller.addPlannerIdea) {
            root.controller.addPlannerIdea(String(templateId || root.templateId || ""), String(topic || ""))
            changed()
            return ({ topic: String(topic || ""), template_id: String(templateId || root.templateId || "") })
        }
        var item = {
            id: String(Date.now()),
            topic: String(topic || ""),
            template_id: String(templateId || ""),
            created_at: new Date().toISOString()
        }
        localIdeas = localIdeas.concat([item])
        changed()
        return item
    }

    function removeIdea(id) {
        if (root.controller && root.controller.deletePlannerIdea) {
            var result = root.controller.deletePlannerIdea(root.templateId, String(id || ""))
            changed()
            return result || ({})
        }
        var next = []
        for (var i = 0; i < root.localIdeas.length; i++) {
            if (String(root.localIdeas[i].id) !== String(id))
                next.push(root.localIdeas[i])
        }
        localIdeas = next
        changed()
        return { ok: true, id: String(id || ""), message: "Planner idea deleted" }
    }

    function applyIdea(id) {
        if (root.controller && root.controller.applyPlannerIdea) {
            var result = root.controller.applyPlannerIdea(root.templateId, String(id || ""))
            var topic = String((result || {}).topic || "")
            if (String(topic || "").length > 0)
                applied(String(topic))
            changed()
            return result || ({})
        }
        for (var i = 0; i < root.localIdeas.length; i++) {
            if (String(root.localIdeas[i].id) === String(id)) {
                root.localIdeas[i].used = true
                applied(String(root.localIdeas[i].topic || ""))
                changed()
                return { ok: true, id: String(id || ""), topic: String(root.localIdeas[i].topic || ""), message: "Planner idea applied" }
            }
        }
        return { ok: false, error: "idea_not_found", message: "Planner apply failed" }
    }
}
