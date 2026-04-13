import { useAuth } from "../../context/useAuth";
// import { useSelection } from "../../context/SelectionContext";
import LoginPage from "./LoginPage";
// import SubjectListPage from "./SubjectListPage";
// import ChapterListPage from "./ChapterListPage";
// import ContentNodePage from "./ContentNodePage";

export default function MainContent() {
  const { isAuthenticated } = useAuth();
  // const { selectedSubject, selectedChapter, selectedTopic } = useSelection();

  // Phase 0: Not logged in
  if (!isAuthenticated) {
    return <LoginPage />;
  }

  // Phase 1: Logged in, no subject
  // if (!selectedSubject) {
  //   return <SubjectListPage />;
  // }

  // Phase 1b: Subject selected, no chapter
  // if (!selectedChapter) {
  //   return <ChapterListPage />;
  // }

  // Phase 2: Inside chapter
  // if (selectedTopic) {
  //   return <ContentNodePage />;
  // }

  return <div>Select a topic from the sidebar.</div>;
}