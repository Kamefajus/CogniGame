func calculate_grade(questions: Dictionary, submitted_answers: Dictionary) -> float:
	var total_score := 0.0
	var total_max_score := 0.0

	for question_id in questions.keys():
		var question = questions[question_id]
		var correct_answers := []
		var selected_correct := false
		var selected_incorrect := false
		total_max_score += question.score

		# Gather correct answer IDs
		for answer in question.answers:
			if answer.is_correct:
				correct_answers.append(answer.answer_id)

		# Check if the user selected anything for this question
		var selected_answers = []
		if submitted_answers.has("question_%d" % question_id):
			selected_answers = submitted_answers["question_%d" % question_id]

		# Single-correct logic
		var question_score := 0.0
		if question.single_correct == 1:
			if typeof(selected_answers) == TYPE_INT:  # Radio button returns a single int
				if selected_answers in correct_answers:
					question_score = question.score
		else:
			# Multi-correct logic
			if typeof(selected_answers) == TYPE_ARRAY:
				var selected_correct_count := 0
				var selected_incorrect_count := 0
				for answer_id in selected_answers:
					if answer_id in correct_answers:
						selected_correct_count += 1
					else:
						selected_incorrect_count += 1

				var total_correct_count = correct_answers.size()
				if total_correct_count > 0:
					question_score = ((selected_correct_count - selected_incorrect_count) / total_correct_count) * question.score

		# Clamp the question score so it doesn't go negative
		question_score = max(question_score, 0)
		total_score += question_score

	# Calculate final grade (0–10 scale)
	var grade := 10.0
	if total_max_score > 0:
		grade = (total_score / total_max_score) * 10.0

	return grade
